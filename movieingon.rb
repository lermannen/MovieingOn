# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'sinatra/base'
require 'sequel'
require 'themoviedb'

require_relative 'model'

class MovieingOn < Sinatra::Base
	def add_actor(actor, movie)
		configuration = Tmdb::Configuration.new

		person = Person.first(:moviedb_id => actor["id"])

	  if person
	    movie.add_actor(person[:id])
	  else
	    movie.add_actor(
	      name: actor["name"],
	      moviedb_id: actor["id"],
	      profile_url: actor["profile_path"].nil? ? nil : "#{configuration.base_url}w185#{actor["profile_path"]}"
	    )
	  end
	end

	def add_cast(movie_id, created_movie_id)
		cast = Tmdb::Movie.casts(movie_id, created_movie_id)

		cast.each do |actor|
	      add_actor(actor, created_movie_id)
	    end
	end

	def add_crew(movie_id, created_movie_id)
		configuration = Tmdb::Configuration.new
		crew = Tmdb::Movie.crew(movie_id)
		crew.each do |crewman|
			person = Person.where(:moviedb_id => crewman["id"]).first

	    if crewman["department"] == "Writing"
	      if person
	        created_movie_id.add_writer(person[:id])
	      else
		      created_movie_id.add_writer(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}w185#{crewman["profile_path"]}"
		      )
		    end
	    elsif crewman["job"] == "Producer"
	      if person
	        created_movie_id.add_producer(person[:id])
	      else
		      created_movie_id.add_producer(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}w185#{crewman["profile_path"]}"
		      )
		    end
	    elsif crewman["job"] == "Director"
	      if person
	        created_movie_id.add_director(person[:id])
	      else
	      	created_movie_id.add_director(
		      	:name => crewman["name"],
		      	:moviedb_id => crewman["id"],
		      	:profile_url => "#{configuration.base_url}w185#{crewman["profile_path"]}"
		      )
	      end
	    end
	  end
	end

	def add_production_company(created_movie_id, company)
		prodco = Productioncompany.where(:moviedb_id => company["id"]).first
      if prodco
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
      if genre_id
        created_movie_id.add_genre(genre_id[:id])
      else
		    created_movie_id.add_genre(
		    	:name => genre["name"],
		    	:moviedb_id => genre["id"]
		    )
		  end
	end

	def add_movie_to_database(movie_id, movieingonrating, imdbrating, episode)
		movie = Tmdb::Movie.detail(movie_id)
		configuration = Tmdb::Configuration.new

		if movie
	    current_movie = Movie.filter(:moviedb_id => movie.id).first
	    fetched_movie_id = current_movie[:moviedb_id] unless current_movie.nil?
	  end

	  DB.transaction do
		  if fetched_movie_id.nil?
				created_movie_id = Movie.create do |m|
					m.moviedb_id = movie.id
					m.title = movie.title
					m.year = movie.release_date.slice(0..3)
					m.imdburl = "http://www.imdb.com/title/#{movie.imdb_id}"
					m.movieingonrating = movieingonrating
					m.imdbrating = imdbrating
					m.poster_url = "#{configuration.base_url}w185#{movie.poster_path}"
					m.episode = episode
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
		@actor_max = actor_max = DB[:actors].group_and_count(:person_id).max(:count)
		@actor = DB[:actors___a].
		  join(:persons___p, :id=>:person_id).
		  group_and_count(:p__name).having(:count => @actor_max).all.map { |actor| actor[:name] }.sort.join(", ")
		@director_max = DB[:directors].group_and_count(:person_id).max(:count)
		@director = DB[:directors___d].
		  join(:persons___p, :id=>:person_id).
		  group_and_count(:p__name).having(:count => @director_max).all.map { |director| director[:name] }.sort.join(", ")
		@production_company_max = DB[:movie_productioncompany].group_and_count(:productioncompany_id).max(:count)
		@production_company = DB[:movie_productioncompany___mpc].
		  join(:productioncompanies___p, :id=>:productioncompany_id).
		  group_and_count(:p__name).having(:count => @production_company_max).all.map { |production_company| production_company[:name] }.sort.join(", ")
		@year = Movie.group_and_count(:year).order(:count).last
		@top_rating = Movie.max(:movieingonrating)
		@top_rated = Movie.where(:movieingonrating => @top_rating).all
		@low_rated = Movie.order(:movieingonrating).first

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
		@moviecount = Movie.count

		erb :actors
	end

	get '/admin' do
		@movies = Movie.all
		@title = 'Movies'
		@moviecount = Movie.count
		erb :admin
	end

	get '/rated' do
		@movies = Movie.select_map([:movieingonrating, :title, :year, :poster_url]).sort.reverse
		@title = 'Our ratings'
		@moviecount = Movie.count
		erb :rated
	end

	post '/' do
		add_movie_to_database(
			params[:movie_id],
			params[:movieingonrating],
			params[:imdbrating],
			params[:episode]
		)

		redirect '/admin'
	end

	run! if app_file == $0 #Om vi kör "ruby movieingon.rb"
end
