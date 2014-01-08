# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'sinatra/base'
require 'sequel'
require 'themoviedb'

require_relative 'model'

class MovieingOn < Sinatra::Base
	get '/' do
		actors = Hash.new{|h,k| h[k] = []}

		Person.all.each do |a|
			if a.actor.count > 1
		  	actors[a.actor.count] << {:actor => a.name, :movies => a.actor.map { |m| m.title}.sort.join(", ")}
		  end
		end

		@actors = actors
		@title = ''
		erb :actors
	end

	get '/admin' do
		@movies = Movie.all
		@title = 'Movies'
		erb :home
	end

	post '/' do
		movie = Tmdb::Movie.detail(params[:movie_id])
		cast = Tmdb::Movie.casts(params[:movie_id])
		crew = Tmdb::Movie.crew(params[:movie_id])

		if !movie.nil?
	    current_movie = Movie.filter(:moviedb_id => movie.id).first
	    movie_id = current_movie[:moviedb_id] unless current_movie.nil?
	  end
	  if movie_id.nil?
			created_movie = Movie.create do |m|
				m.moviedb_id = movie.id
				m.title = movie.title
				m.year = movie.release_date
				m.imdburl = "http://www.imdb.com/title/#{movie.imdb_id}"
				m.movieingonrating = params[:movieingonrating]
				m.imdbrating = params[:imdbrating]
			end

			movie.production_companies.each do |company|
		    prodco = Productioncompany.where(:moviedb_id => company["id"]).first
	      if !prodco.nil?
	        created_movie.add_productioncompany(prodco[:id])
	      else
			    created_movie.add_productioncompany(
			    	:name => company["name"],
			    	:moviedb_id => company["id"]
			    )
			  end
		  end

		  cast.each do |actor|
	      person = Person.where(:moviedb_id => actor["id"]).first
	      if !person.nil?
	        created_movie.add_actor(person[:id])
	      else
	        created_movie.add_actor(
	          :name => actor["name"],
	          :moviedb_id => actor["id"]
	        )
	      end
	    end

		  crew.each do |crewman|
		    if crewman["department"] == "Writing"
		      person = Person.where(:moviedb_id => crewman["id"]).first
		      if !person.nil?
		        created_movie.add_writer(person[:id])
		      else
			      created_movie.add_writer(
			      	:name => crewman["name"],
			      	:moviedb_id => crewman["id"]
			      )
			    end
		    elsif crewman["job"] == "Producer"
		      person = Person.where(:moviedb_id => crewman["id"]).first
		      if !person.nil?
		        created_movie.add_producer(person[:id])
		      else
			      created_movie.add_producer(
			      	:name => crewman["name"],
			      	:moviedb_id => crewman["id"]
			      )
			    end
		    elsif crewman["job"] == "Director"
		      person = Person.where(:moviedb_id => crewman["id"]).first
		      if !person.nil?
		        created_movie.add_director(person[:id])
		      else
		      	created_movie.add_director(
			      	:name => crewman["name"],
			      	:moviedb_id => crewman["id"]
			      )
		      end
		    end
		  end
		end

		redirect '/admin'
	end

	run! if app_file == $0 #Om vi kör "ruby movieingon.rb"
end
