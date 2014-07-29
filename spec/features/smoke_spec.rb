require "feature_spec_helper"

RSpec.describe "happy path", feature: true do
	let(:example_movie) {
		{
			"moviedb_id" => 4711,
			"movieingonrating" => "7.1",
			"imdbrating" => "6"
		}
	}

	specify "adding a movie" do
		expect(db[:movies]).to be_empty
		expect(db[:persons]).to be_empty
		
		pending "not implemented."
		# fetch movie data (mock) (vcr?)
		# add movie
		# ensure end result
	end
end