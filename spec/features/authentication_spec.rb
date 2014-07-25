require "feature_spec_helper"

RSpec.describe "authentication", feature: true do
	specify "login in as administrator" do
		authorize 'admin', ENV["ADMIN_PASSWORD"]
    get '/admin'
    expect(last_response.status).to eq(200)
	end

	specify "login without authentication" do
    get '/admin'
    expect(last_response.status).to eq(401)
  end

  specify "login with bad credentials" do
    authorize 'bad', 'boy'
    get '/admin'
    expect(last_response.status).to eq(401)
  end
end