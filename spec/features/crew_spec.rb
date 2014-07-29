require "feature_spec_helper"

RSpec.describe "adding crew", feature: true do
	
  specify "add crew when person exists" do
		expect(db[:movies]).to be_empty
    expect(db[:persons]).to be_empty

    # Add movie and person
    movie_id = DB[:movies].insert(
      moviedb_id: 4711,
      title: "Test movie",
      year: 1900,
      imdburl: "http://",
      movieingonrating: 1,
      imdbrating: 1,
      episode: 1)

    person_id = DB[:persons].insert(
      name: "Test Crew",
      moviedb_id: 100,
      profile_url: "http://")
    
    # Add person
    person = {name: "Test Crew", id: 100, profile_url: "http://", job: :writer}
    helper = MovieHelper.new
    helper.add_crewman(person, movie_id)

    # Ensure that the end state is valid
    expect(db[:persons].all.length).to eq(1)
    expect(db[:crew].all.length).to eq(1)
	end

  specify "add crew when person does not exists" do
    expect(db[:movies]).to be_empty
    expect(db[:persons]).to be_empty

    # Add movie
    movie_id = DB[:movies].insert(
      moviedb_id: 4711,
      title: "Test movie",
      year: 1900,
      imdburl: "http://",
      movieingonrating: 1,
      imdbrating: 1,
      episode: 1)
    
    # Add person
    person = {name: "Test Crew", id: 100, profile_url: "http://", job: :director}
    helper = MovieHelper.new
    helper.add_crewman(person, movie_id)

    # Ensure that the end state is valid
    expect(db[:persons].all.length).to eq(1)
    expect(db[:crew].all.length).to eq(1)
  end

end