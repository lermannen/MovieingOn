require "feature_spec_helper"

RSpec.describe "adding actors", feature: true do
	
  specify "add actor when person exists" do
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
      name: "Test Actor",
      moviedb_id: 100,
      profile_url: "http://")
    
    # Add actor
    actor = {name: "Test Actor", moviedb_id: 100, profile_url: "http://"}
    helper = MovieHelper.new
    helper.add_actor(actor, movie_id)

    # Ensure that the end state is valid
    expect(db[:persons].all.length).to eq(1)
	end

  specify "add actor when person does not exists" do
    expect(db[:movies]).to be_empty
    expect(db[:persons]).to be_empty

    # Add movie
    # Add movie and person
    movie_id = DB[:movies].insert(
      moviedb_id: 4711,
      title: "Test movie",
      year: 1900,
      imdburl: "http://",
      movieingonrating: 1,
      imdbrating: 1,
      episode: 1)
    
    # Add actor
    actor = {name: "Test Actor", moviedb_id: 100, profile_url: "http://"}
    helper = MovieHelper.new
    helper.add_actor(actor, movie_id)

    # Ensure that the end state is valid
    expect(db[:persons].all.length).to eq(1)
  end

end