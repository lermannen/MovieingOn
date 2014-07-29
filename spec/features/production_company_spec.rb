require "feature_spec_helper"

RSpec.describe "adding production company", feature: true do
	
  specify "add production company when it doesn't exist" do
		expect(db[:movies]).to be_empty
    expect(db[:productioncompanies]).to be_empty

    # Add movie
    movie_id = DB[:movies].insert(
      moviedb_id: 4711,
      title: "Test movie",
      year: 1900,
      imdburl: "http://",
      movieingonrating: 1,
      imdbrating: 1,
      episode: 1)

    # Add production company
    production_company = {name: "Test Company", id: 100}
    helper = MovieHelper.new
    production_company_id = helper.add_production_company(production_company, movie_id)

    # Ensure that the end state is valid
    expect(db[:productioncompanies].all.length).to eq(1)
    expect(db[:movie_productioncompany].all.length).to eq(1)

    db[:productioncompanies].all.should include(
      id: production_company_id,
      name: "Test Company",
      moviedb_id: 100
    )

    db[:movie_productioncompany].all.should include(
      movie_id: movie_id,
      productioncompany_id: production_company_id)
	end

  specify "add production company when it already exist" do
    expect(db[:movies]).to be_empty
    expect(db[:productioncompanies]).to be_empty

    # Add movie
    movie_id = DB[:movies].insert(
      moviedb_id: 4711,
      title: "Test movie",
      year: 1900,
      imdburl: "http://",
      movieingonrating: 1,
      imdbrating: 1,
      episode: 1)

    production_company_id = DB[:productioncompanies].insert(
      name: "Test Company",
      moviedb_id: 100)

    # Add production company
    production_company = {name: "Test Company", id: 100}
    helper = MovieHelper.new
    helper.add_production_company(production_company, movie_id)

    # Ensure that the end state is valid
    expect(db[:productioncompanies].all.length).to eq(1)
    expect(db[:movie_productioncompany].all.length).to eq(1)

    db[:productioncompanies].all.should include(
      id: production_company_id,
      name: "Test Company",
      moviedb_id: 100
    )

    db[:movie_productioncompany].all.should include(
      movie_id: movie_id,
      productioncompany_id: production_company_id)
  end

end