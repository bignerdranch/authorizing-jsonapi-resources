RSpec.shared_examples "with an access token" do
  before do
    post "/oauth/token", params: {
      grant_type: "password",
      username: me.email,
      password: "password"
    }
  end

  let(:get_headers) {{
    "Authorization": "Bearer #{JSON.parse(response.body)['access_token']}",
    "Accept": "application/vnd.api+json",
  }}
end
