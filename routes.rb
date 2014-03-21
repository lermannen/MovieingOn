require 'sinatra'
require_relative 'movieingonhelpers'

class MovieingOn < Sinatra::Base
  helpers Sinatra::MovieingOnHelpers

  get '/' do
    @actor_max = DB[:actors].group_and_count(:person_id).max(:count)

    @actor = DB[:actors___a]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).having(count: @actor_max).all
      .map { |actor| actor[:name] }.sort.join(', ')

    @director_max = DB[:directors].group_and_count(:person_id).max(:count)

    @director = DB[:directors___d]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).having(count: @director_max).all
      .map { |director| director[:name] }.sort.join(', ')

    @production_company_max = DB[:movie_productioncompany]
      .group_and_count(:productioncompany_id).max(:count)

    @production_company = DB[:movie_productioncompany___mpc]
      .join(:productioncompanies___p, id: :productioncompany_id)
      .group_and_count(:p__name).having(count: @production_company_max).all
      .map { |production_company| production_company[:name] }.sort.join(', ')
    @year = Movie.group_and_count(:year).order(:count).last
    @top_rating = Movie.max(:movieingonrating)
    @top_rated = Movie.where(movieingonrating: @top_rating).all
    @low_rated = Movie.order(:movieingonrating).first

    actors = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |a|
      if a.actor.count > 1
        actors[a.actor.count] << {
          actor: a.name,
          movies: a.actor.map { |m| m.title }.sort.join(', ')
        }
      end
    end

    @actors = actors

    @title = ''
    @moviecount = Movie.count

    erb :home
  end

  get '/admin' do
    protected!
    @movies = Movie.all
    @title = 'Movies'
    @moviecount = Movie.count
    erb :admin
  end

  get '/movie' do
    @movies = Movie.all
    @title = 'Movies'
    @moviecount = Movie.count
    erb :movie
  end

  get '/actors' do
    @actor_max = DB[:actors].group_and_count(:person_id).max(:count)
    @actor = DB[:actors___a]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).having(count: @actor_max).all
      .map { |actor| actor[:name] }.sort.join(', ')

    actors = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |a|
      if a.actor.count > 1
        actors[a.actor.count] << {
          actor: a.name,
          movies: a.actor.map { |m| m.title }.sort.join(', '),
          id: a.moviedb_id
        }
      end
    end

    @actors = actors

    @title = ''
    @moviecount = Movie.count

    erb :actors
  end

  get '/directors' do
    @director_max = DB[:directors].group_and_count(:person_id).max(:count)
    @director = DB[:directors___a]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).having(count: @director_max).all
      .map { |director| director[:name] }.sort.join(', ')

    directors = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |a|
      if a.director.count > 1
        directors[a.director.count] << {
          director: a.name,
          movies: a.director.map { |m| m.title }.sort.join(', ')
        }
      end
    end

    @directors = directors

    @title = ''
    @moviecount = Movie.count

    erb :directors
  end

  get '/writers' do
    @writer_max = DB[:writers].group_and_count(:person_id)
    .max(:count)
    @writer = DB[:writers___a]
      .join(:persons___p, id: :person_id)
      .group_and_count(:p__name).having(count: @writer_max).all
      .map { |writer| writer[:name] }.sort.join(', ')

    writers = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |a|
      if a.writer.count > 1
        writers[a.writer.count] << {
          writer: a.name,
          movies: a.writer.map { |m| m.title }.sort.join(', ')
        }
      end
    end

    @writers = writers

    @title = ''
    @moviecount = Movie.count

    erb :writers
  end

  get '/rated' do
    @movies = Movie.select_map([:movieingonrating, :title, :year, :poster_url, :moviedb_id])
      .sort.reverse
    @title = 'Our ratings'
    @moviecount = Movie.count
    erb :rated
  end

  get '/person/:person_id' do |person_id|
    @person = Person[moviedb_id: person_id]
    @title = @person.name
    @movies = Person[moviedb_id: person_id].actor
    erb :person
  end

  get '/movie/:movie_id' do |movie_id|
    @movie = Movie[moviedb_id: movie_id]
    @title = @movie.title
    @actors = Movie[moviedb_id: movie_id].actor
    erb :episode
  end

  get '/episode/:episode' do |episode|
    @movie = Movie[episode: episode]
    @title = @movie.title
    @actors = Movie[episode: episode].actor
    erb :episode
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
end
