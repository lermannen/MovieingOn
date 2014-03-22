require 'sinatra'
require_relative 'lib/movieingonhelpers'

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
    @people = get_top_list('actor')
    @title = ''
    @job = 'actors'
    erb :people
  end

  get '/directors' do
    @people = get_top_list('director')
    @title = ''
    @job = 'directors'
    erb :people
  end

  get '/writers' do
    @people = get_top_list('writer')
    @title = ''
    @job = 'writers'
    erb :people
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
    @movies = Person[moviedb_id: person_id].movies
    erb :person
  end

  get '/movie/:movie_id' do |movie_id|
    @movie = Movie[moviedb_id: movie_id]
    @title = @movie.title
    @actors = Movie[moviedb_id: movie_id].crew
    erb :episode
  end

  get '/episode/:episode' do |episode|
    @movie = Movie[episode: episode]
    @title = @movie.title
    @actors = Movie[episode: episode].crew
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
