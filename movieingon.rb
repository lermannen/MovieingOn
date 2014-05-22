require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'sinatra/base'
require 'sequel'

require_relative 'model'
require_relative 'routes/routes'
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
      } unless movie_list.count <= 1
    end

    persons
  end

  def job_max(job)
    DB[:crew].group_and_count(:person_id).where(job: job).max(:count)
  end

  def job_toplist(job, max_count)
    DB[:crew___a]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).where(job: job).having{count(:*){} >= max_count}.all
      .map { |person| person[:name] }.sort.join(', ')
  end

  def add_actor(actor, movie)
    person = Person.first(moviedb_id: actor['id'])

    if person
      ds = DB[:crew]
      ds.insert(person_id: person.id, movie_id: movie.id, job: 'actor')
    else
      ds = DB[:persons]
      person_id = ds.insert(
        name: actor.name,
        moviedb_id: actor.id,
        profile_url: actor.profile_path)
      ds = DB[:crew]
      ds.insert(person_id: person_id, movie_id: movie.id, job: 'actor')
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
      if person
        ds = DB[:crew]
        ds.insert(
          person_id: person.id,
          movie_id: created_movie_id.id,
          job: crewman.job.to_s)
      else
        ds = DB[:persons]
        person_id = ds.insert(
          name: crewman.name,
          moviedb_id: crewman.id,
          profile_url: crewman.profile_path)
        ds = DB[:crew]
        ds.insert(
          person_id: person_id,
          movie_id: created_movie_id.id,
          job: crewman.job.to_s)
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
