# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'sinatra/base'
require 'sequel'
require 'themoviedb'

require_relative 'model'

class MovieingOn < Sinatra::Base
	def add_cast(movie_id, created_movie_id)
		configuration = Tmdb::Configuration.new
		cast = Tmdb::Movie.casts(movie_id, created_movie_id)

		cast.each do |actor|
	      person = Person.where(:moviedb_id => actor["id"]).first
	      if !person.nil?
	        created_movie_id.add_actor(person[:id])
	      else
	        created_movie_id.add_actor(
	          :name => actor["name"],
	          :moviedb_id => actor["id"],
	          :profile_url => "#{configuration.base_url}/w185/#{actor["profile_path"]}"
	        )
	      end
	    end
	end

	def add_crew(movie_id, created_movie_id)
		configuration = Tmdb::Configuration.new
		crew = Tmdb::Movie.crew(movie_id)
		crew.each do |crewman|
			person = Person.where(:moviedb_id => crewman["id"]).first
	    
	    if crewman["department"] == "Writing"
	      if !person.nil?
	        created_movie_id.add_writer(person[:id])
	      else
		      created_movie_id.add_writer(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}/w185/#{crewman["profile_path"]}"
		      )
		    end
	    elsif crewman["job"] == "Producer"
	      if !person.nil?
	        created_movie_id.add_producer(person[:id])
	      else
		      created_movie_id.add_producer(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}/w185/#{crewman["profile_path"]}"
		      )
		    end
	    elsif crewman["job"] == "Director"
	      if !person.nil?
	        created_movie_id.add_director(person[:id])
	      else
	      	created_movie_id.add_director(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}/w185/#{crewman["profile_path"]}"
		      )
	      end
	    end
	  end
	end

	def add_production_company(created_movie_id, company)
		prodco = Productioncompany.where(:moviedb_id => company["id"]).first
      if !prodco.nil?
        created_movie_id.add_productioncompany(prodco[:id])
      else
		    created_movie_id.add_productioncompany(
		    	:name => company["name"],
		    	:moviedb_id => company["id"]
		    )
		  end
	end

	def add_genre(created_movie_id, genre)
		genre_id = Genre.where(:moviedb_id => genre["id"]).first
      if !genre_id.nil?
        created_movie_id.add_genre(genre_id[:id])
      else
		    created_movie_id.add_genre(
		    	:name => genre["name"],
		    	:moviedb_id => genre["id"]
		    )
		  end
	end

	def add_movie_to_database(movie_id, movieingonrating, imdbrating)
		movie = Tmdb::Movie.detail(movie_id)
		configuration = Tmdb::Configuration.new

		if !movie.nil?
	    current_movie = Movie.filter(:moviedb_id => movie.id).first
	    fetched_movie_id = current_movie[:moviedb_id] unless current_movie.nil?
	  end

	  DB.transaction do
		  if fetched_movie_id.nil?
				created_movie_id = Movie.create do |m|
					m.moviedb_id = movie.id
					m.title = movie.title
					m.year = movie.release_date
					m.imdburl = "http://www.imdb.com/title/#{movie.imdb_id}"
					m.movieingonrating = movieingonrating
					m.imdbrating = imdbrating
					m.poster_url = "#{configuration.base_url}/w185/#{movie.poster_path}"
				end

				movie.production_companies.each do |company|
			    add_production_company(created_movie_id, company)
			  end

			  movie.genres.each do |genre|
			  	add_genre(created_movie_id, genre)
			  end

			  add_cast(movie_id, created_movie_id)
			  add_crew(movie_id, created_movie_id)

			end
		end
	end

	get '/' do
		actors = Hash.new{|h,k| h[k] = []}

		Person.all.each do |a|
			if a.actor.count > 1
		  	actors[a.actor.count] << {
		  		:actor => a.name,
		  		:movies => a.actor.map { |m| m.title}.sort.join(", ")
		  	}
		  end
		end

		@actors = actors
		@title = ''
		erb :actors
	end

	get '/admin' do
		@movies = Movie.all
		@title = 'Movies'
		erb :admin
	end

	get '/toprated' do
		@movies = Movie.select_map([:movieingonrating, :title, :year]).sort.reverse
		@title = 'Movies - top rated'
		erb :top_rated
	end

	get '/lowestrated' do
		@movies = Movie.select_map([:movieingonrating, :title, :year]).sort
		@title = 'Movies - lowerst rated'
		erb :lowest_rated
	end

	post '/' do
		add_movie_to_database(
			params[:movie_id], 
			params[:movieingonrating], 
			params[:imdbrating]
		)

		redirect '/admin'
	end

	run! if app_file == $0 #Om vi kör "ruby movieingon.rb"
end
