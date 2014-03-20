# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'sinatra/base'
require 'sequel'
require 'themoviedb'

require_relative 'model'
require_relative 'routes'

# Base class for the MovieingOne application.
class MovieingOn < Sinatra::Base
  attr_reader :configuration

  def initialize
    super
    @configuration = Tmdb::Configuration.new
    Tmdb::Api.key('f6343dcd785009de63b392bc4ac98e89')
  end

  def add_actor(actor, movie)
    person = Person.first(moviedb_id: actor['id'])

    if person
      movie.add_actor(person[:id])
    else
      movie.add_actor(
        name: actor['name'],
        moviedb_id: actor['id'],
        profile_url: actor['profile_path']
          .nil? ? nil : "#{configuration.base_url}w185#{actor['profile_path']}"
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
    crew = Tmdb::Movie.crew(movie_id)
    crew.each do |crewman|
      person = Person.where(moviedb_id: crewman['id']).first

      if crewman['department'] == 'Writing'
        if person
          created_movie_id.add_writer(person[:id])
        else
          created_movie_id.add_writer(
            name: crewman['name'],
            moviedb_id: crewman['id'],
            profile_url: "#{configuration.base_url}w185#{crewman['profile_path']}"
          )
        end
      elsif crewman['job'] == 'Producer'
        if person
          created_movie_id.add_producer(person[:id])
        else
          created_movie_id.add_producer(
            name: crewman['name'],
            moviedb_id: crewman['id'],
            profile_url: "#{configuration.base_url}w185#{crewman['profile_path']}"
          )
        end
      elsif crewman['job'] == 'Director'
        if person
          created_movie_id.add_director(person[:id])
        else
          created_movie_id.add_director(
            name: crewman['name'],
            moviedb_id: crewman['id'],
            profile_url: "#{configuration.base_url}w185#{crewman['profile_path']}"
          )
        end
      end
    end
  end

  def add_production_company(created_movie_id, company)
    prodco = Productioncompany.where(moviedb_id: company['id']).first
    if prodco
      created_movie_id.add_productioncompany(prodco[:id])
    else
      created_movie_id.add_productioncompany(
        name: company['name'],
        moviedb_id: company['id']
      )
    end
  end

  def add_genre(created_movie_id, genre)
    genre_id = Genre.where(moviedb_id: genre['id']).first
    if genre_id
      created_movie_id.add_genre(genre_id[:id])
    else
      created_movie_id.add_genre(
        name: genre['name'],
        moviedb_id: genre['id']
      )
    end
  end

  def add_movie_to_database(movie_id, movieingonrating, imdbrating, episode)
    movie = Tmdb::Movie.detail(movie_id)

    if movie
      current_movie = Movie.filter(moviedb_id: movie.id).first
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

  run! if app_file == $PROGRAM_NAME # If we run using 'ruby movieingon.rb'
end
