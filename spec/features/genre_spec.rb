require "feature_spec_helper"

RSpec.describe "adding genres", feature: true do
	
  specify "add genre to movie" do
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
    
    # Add genre
    genre = {name: "Action", id: 100}
    helper = MovieHelper.new
    helper.add_genre(genre, movie_id)

    # Ensure that the end state is valid
    expect(db[:genres].all.length).to eq(1)
	end

  specify "add genre to movie when genre already exists" do
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

    genre_id = DB[:genres].insert(
      name: "Action",
      moviedb_id: 100)
    
    # Add genre
    genre = {name: "Action", id: 100}
    helper = MovieHelper.new
    helper.add_genre(genre, movie_id)

    # Ensure that the end state is valid
    expect(db[:genres].all.length).to eq(1)
  end

end