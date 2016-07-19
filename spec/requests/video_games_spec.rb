require "rails_helper"

RSpec.describe "/video-games" do

  let(:me) { FactoryGirl.create(:user, password: "password") }
  let!(:games) { FactoryGirl.create_list(:video_game, 3, user: me) }

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
        get "/video-games", headers: get_headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
      include_context "with an access token"

      it "returns all video games" do
        get "/video-games", headers: get_headers

        expect(response.status).to eq(200)
        expect(response_games).to_not be_nil
        expect(response_games.count).to eq(games.count)

        response_titles = response_games.map{|n| n["attributes"]["title"]}
        expect(response_titles).to match_array(games.map(&:title))
      end
    end
  end

  describe "GET #show" do
    let(:game) { games[0] }
    context "not authenticated" do
      it "returns an unauthorized status" do
        get "/video-games/#{game.id}", headers: get_headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
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
  end

  describe "POST #create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { JSON.dump({
      "data": {
        "type": "video-games",
        "attributes": {
          title: "New Game",
        },
        "relationships": {
          "user": {
            "data": { "type": "users", "id": user.id }
          }
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

      it "creates a game" do
        expect {
          post "/video-games", params: params, headers: headers
        }.to change{ VideoGame.count }.by(1)

        expect(response.status).to eq(201)

        new_game = VideoGame.last

        expect(new_game.user).to eq(user)
        expect(new_game.title).to eq("New Game")
      end
    end
  end

  describe "PATCH #update" do
    let(:game) { games[0] }
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

    context "authenticated" do
      include_context "with an access token"

      let(:response_game) { response_json["data"] }
      it "updates fields on the game" do
        patch "/video-games/#{game.id}", params: params, headers: headers

        expect(response.status).to eq(200)

        expect(game.reload.title).to eq("Updated Game")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:game) { games[0] }
    context "not authenticated" do
      it "returns an unauthorized status" do
        delete "/video-games/#{game.id}", headers: headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
      include_context "with an access token"

      it "deletes the game" do
        expect {
          delete "/video-games/#{game.id}", headers: headers
        }.to change{ VideoGame.count }.by(-1)

        expect(response.status).to eq(204)

        expect{game.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
