require "rails_helper"

RSpec.describe "/video-games" do

  let(:me) { FactoryGirl.create(:user, password: "password") }
  let(:followed) { FactoryGirl.create(:user) }
  let!(:follow) { FactoryGirl.create(:follow, follower: me, followed: followed) }

  let(:someone_else) { FactoryGirl.create(:user) }

  let(:my_games) { FactoryGirl.create_list(:video_game, 3, user: me) }
  let(:followed_games) { FactoryGirl.create_list(:video_game, 3, user: followed) }
  let(:someone_elses_games) { FactoryGirl.create_list(:video_game, 3, user: someone_else) }

  let(:my_visible_games) { my_games + followed_games }
  let!(:all_games) { my_visible_games + someone_elses_games }

  let(:response_json) { JSON.parse(response.body) }
  let(:response_games) { response_json["data"] }

  let(:get_headers) {{
    "Accept": "application/vnd.api+json"
  }}
  let(:headers) {
    get_headers.merge({ "Content-Type": "application/vnd.api+json" })
  }

  describe "GET #index" do
    context "not authenticated" do
      it "returns an unauthorized status" do
        get "/video-games?include=user", headers: get_headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
      include_context "with an access token"

      it "returns all of the user's and friends' video games" do
        get "/video-games?include=user", headers: get_headers

        expect(response.status).to eq(200)
        expect(response_games).to_not be_nil
        expect(response_games.count).to eq(my_visible_games.count)

        response_titles = response_games.map{|n| n["attributes"]["title"]}
        expect(response_titles).to match_array(my_visible_games.map(&:title))

        expect(response_games[0]["relationships"]["user"]["data"]).to be_present
        expect(response_games[0]["relationships"]["user"]["data"]["id"]).to eq(me.id.to_s)
        expect(response_json["included"]).to be_present
        expect(response_json["included"][0]["type"]).to eq("users")
        expect(response_json["included"][0]["id"]).to eq(me.id.to_s)
      end
    end
  end

  describe "GET #show" do
    let(:game) { my_games[0] }

    context "not authenticated" do
      it "returns an unauthorized status" do
        get "/video-games/#{game.id}", headers: get_headers
        expect(response.status).to eq(401)
      end
    end

    context "my game" do
      include_context "with an access token"

      let(:response_game) { response_json["data"] }
      it "returns the specified game" do
        get "/video-games/#{game.id}", headers: get_headers

        expect(response.status).to eq(200)
        expect(response_game).to_not be_nil
        expect(response_game["id"]).to eql(game.id.to_s)
        expect(response_game["attributes"]["title"]).to eq(game.title)
      end
    end

    context "someone else's game" do
      include_context "with an access token"

      let(:game) { someone_elses_games[0] }
      it "returns a not-found status" do
        get "/video-games/#{game.id}", headers: get_headers
        expect(response.status).to eq(404)
      end
    end
  end

  describe "POST #create" do
    let(:params) { JSON.dump({
      "data": {
        "type": "video-games",
        "attributes": {
          title: "New Game",
        }
      }
    }) }
    context "not authenticated" do
      it "returns an unauthorized status" do
        post "/video-games", params: params, headers: headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
      include_context "with an access token"

      it "creates a game for me" do
        expect {
          post "/video-games", params: params, headers: headers
        }.to change{ VideoGame.count }.by(1)

        expect(response.status).to eq(201)

        new_game = VideoGame.last

        expect(new_game.user).to eq(me)
        expect(new_game.title).to eq("New Game")
      end
    end

    context "attempting to create for another user" do
      include_context "with an access token"
      let(:params) { JSON.dump({
        "data": {
          "type": "video-games",
          "attributes": {
            title: "New Game",
          },
          "relationships": {
            "user": {
              "data": { "type": "users", "id": someone_else.id }
            }
          }
        }
      }) }

      it "creates for logged in user anyway" do
        expect {
          post "/video-games", params: params, headers: headers
        }.to change{ VideoGame.count }.by(0)

        expect(response.status).to eq(400)
        expect(response_json["errors"].count).to eq(1)
        expect(response_json["errors"][0]["detail"]).to eq("user is not allowed.")
      end
    end
  end

  describe "PATCH #update" do
    let(:game) { my_games[0] }
    let(:params) { JSON.dump({
      "data": {
        "type": "video-games",
        "id": game.id,
        "attributes": {
          title: "Updated Game",
        }
      }
    }) }

    context "not authenticated" do
      it "returns an unauthorized status" do
        patch "/video-games/#{game.id}", params: params, headers: headers
        expect(response.status).to eq(401)
      end
    end

    context "my game" do
      include_context "with an access token"

      let(:response_game) { response_json["data"] }
      it "updates fields on the game" do
        patch "/video-games/#{game.id}", params: params, headers: headers

        expect(response.status).to eq(200)

        expect(game.reload.title).to eq("Updated Game")
      end
    end

    context "followed's game" do
      include_context "with an access token"

      let(:game) { followed_games[0] }
      it "returns a forbidden status" do
        patch "/video-games/#{game.id}", params: params, headers: headers
        expect(response.status).to eq(403)
      end
    end

    context "someone else's game" do
      include_context "with an access token"

      let(:game) { someone_elses_games[0] }
      it "returns a not-found status" do
        patch "/video-games/#{game.id}", params: params, headers: headers
        expect(response.status).to eq(404)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:game) { my_games[0] }

    context "not authenticated" do
      it "returns an unauthorized status" do
        delete "/video-games/#{game.id}", headers: headers
        expect(response.status).to eq(401)
      end
    end

    context "my game" do
      include_context "with an access token"

      it "deletes the game" do
        expect {
          delete "/video-games/#{game.id}", headers: headers
        }.to change{ VideoGame.count }.by(-1)

        expect(response.status).to eq(204)

        expect{game.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "followed's game" do
      include_context "with an access token"

      let(:game) { followed_games[0] }
      it "returns a forbidden status" do
        delete "/video-games/#{game.id}", headers: headers
        expect(response.status).to eq(403)
      end
    end

    context "someone else's game" do
      include_context "with an access token"

      let(:game) { someone_elses_games[0] }
      it "returns a not-found status" do
        delete "/video-games/#{game.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end
  end
end
