# encoding: utf-8

require 'sqlite3'
require 'sinatra'
require 'sequel'
require 'themoviedb'

DB = Sequel.sqlite('./movieingon.db')

Tmdb::Api.key("f6343dcd785009de63b392bc4ac98e89")

get '/' do
	@movies = DB[:movie]
	@actors = DB
	@title = 'Movies'
	erb :home
end

post '/' do
	movie = Tmdb::Movie.detail(params[:movie_id])
	cast = Tmdb::Movie.casts(params[:movie_id])
	crew = Tmdb::Movie.crew(params[:movie_id])

	movie_id = DB[:movie].insert(
		:title => movie.title,
		:year => movie.release_date,
		:imdburl => "http://www.imdb.com/title/#{movie.imdb_id}",
		:movieingonrating => params[:movieingonrating],
		:imdbrating => params[:imdbrating]
	)
	movie.production_companies.each do |company|
		company = DB[:production_company].insert(:name => company["name"])
		DB[:movie_production_company].insert(:movie_id => movie_id, :production_company_id => company)
	end

	cast.each do |actor|
		person = DB[:person].insert(:name => actor["name"])
		actors = DB[:actors].insert(:person_id => person, :movie_id => movie_id)
	end

	crew.each do |crewman|
  	if crewman["department"] == "Writing"
    	person = DB[:person].insert(:name => crewman["name"])
			DB[:writers].insert(:person_id => person, :movie_id => movie_id)
  	elsif crewman["job"] == "Producer"
  		person = DB[:person].insert(:name => crewman["name"])
			DB[:producers].insert(:person_id => person, :movie_id => movie_id)
  	elsif crewman["job"] == "Director"
  		person = DB[:person].insert(:name => crewman["name"])
			DB[:directors].insert(:person_id => person, :movie_id => movie_id)
  	end
	end

	redirect '/'
end
