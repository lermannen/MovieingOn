# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'sinatra/base'
require 'sequel'

require_relative 'model'
require_relative 'routes'
require_relative 'lib/themoviedb'

# Base class for the MovieingOne application.
class MovieingOn < Sinatra::Base
  attr_reader :themoviedb

  def initialize
    super
    @themoviedb = TheMovieDB.new
  end

  def get_top_list(job)
    persons = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |p|
      movie_list = p.movies_dataset.where(job: job).all
      persons[movie_list.count] << {
        name: p.name,
        movies: movie_list.map { |m| m.title }.sort.join(', ')
      } unless movie_list.count == 0
    end

    persons
  end

  def add_actor(actor, movie)
    person = Person.first(moviedb_id: actor['id'])

    if person
      movie.add_actor(person.id)
    else
      movie.add_actor(
        name: actor.name,
        moviedb_id: actor.id,
        profile_url: actor.profile_path
      )
    end
  end

  def add_cast(movie_id, created_movie_id)
    actors = themoviedb.actors(movie_id)

    actors.each do |actor|
      add_actor(actor, created_movie_id)
    end
  end

  def add_crew(movie_id, created_movie_id)
    crew = themoviedb.crew(movie_id)
    crew.each do |crewman|
      person = Person.where(moviedb_id: crewman.id).first
      if crewman.job == :writer
        if person
          created_movie_id.add_writer(person.id)
        else
          created_movie_id.add_writer(
            name: crewman.name,
            moviedb_id: crewman.id,
            profile_url: crewman.profile_path
          )
        end
      elsif crewman.job == :producer
        if person
          created_movie_id.add_producer(person[:id])
        else
          created_movie_id.add_producer(
            name: crewman.name,
            moviedb_id: crewman.id,
            profile_url: crewman.profile_path
          )
        end
      elsif crewman.job == :director
        if person
          created_movie_id.add_director(person[:id])
        else
          created_movie_id.add_director(
            name: crewman.name,
            moviedb_id: crewman.id,
            profile_url: crewman.profile_path
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
    movie = themoviedb.movie_details(movie_id)

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
          m.poster_url = themoviedb.image_url(movie.poster_path)
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
