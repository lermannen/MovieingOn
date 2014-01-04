# encoding: utf-8

require 'sqlite3'
require 'sinatra'
require 'sequel'
require 'themoviedb'
require_relative 'model'

get '/' do
	@movies = Movie.all
	@title = 'Movies'
	erb :home
end

post '/' do
	movie = Tmdb::Movie.detail(params[:movie_id])
	cast = Tmdb::Movie.casts(params[:movie_id])
	crew = Tmdb::Movie.crew(params[:movie_id])

	movie_id = Movie.insert(
		:moviedb_id => movie.id,
		:title => movie.title,
		:year => movie.release_date,
		:imdburl => "http://www.imdb.com/title/#{movie.imdb_id}",
		:movieingonrating => params[:movieingonrating],
		:imdbrating => params[:imdbrating]
	)

	movie.production_companies.each do |company|
    company = Productioncompany.insert(:name => company["name"], :moviedb_id => company["id"])
    DB[:movie_productioncompany].insert(:movie_id => movie_id, :productioncompany_id => company)
  end

  cast.each do |actor|
    person = Person.insert(:name => actor["name"], :moviedb_id => actor["id"])
    actors = DB[:actors].insert(:person_id => person, :movie_id => movie_id)
  end

  crew.each do |crewman|
    if crewman["department"] == "Writing"
      person = Person.insert(:name => crewman["name"], :moviedb_id => crewman["id"])
      DB[:writers].insert(:person_id => person, :movie_id => movie_id)
    elsif crewman["job"] == "Producer"
      person = Person.insert(:name => crewman["name"], :moviedb_id => crewman["id"])
      DB[:producers].insert(:person_id => person, :movie_id => movie_id)
    elsif crewman["job"] == "Director"
      person = Person.insert(:name => crewman["name"], :moviedb_id => crewman["id"])
      DB[:directors].insert(:person_id => person, :movie_id => movie_id)
    end
  end

	redirect '/'
end
