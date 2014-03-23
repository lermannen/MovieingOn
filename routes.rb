require 'sinatra'
require_relative 'lib/movieingonhelpers'

# Routes for the application.
class MovieingOn < Sinatra::Base
  helpers Sinatra::MovieingOnHelpers

  get '/' do
    @actor_max = job_max('actor')
    @actor = job_toplist('actor', @actor_max)

    @director_max = job_max('director')
    @director = job_toplist('director', @director_max)

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

    @actors = get_top_list('actor')
    @title = ''
    @moviecount = Movie.count

    erb :home
  end

  get '/admin' do
    # protected!
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
    @header = 'The following actors have acted more than one movie:'
    @moviecount = Movie.count
    erb :people
  end

  get '/directors' do
    @people = get_top_list('director')
    @title = ''
    @header = 'The following directors have directed more than one movie:'
    @moviecount = Movie.count
    erb :people
  end

  get '/writers' do
    @people = get_top_list('writer')
    @title = ''
    @header = 'The following writers have written more than one movie:'
    @moviecount = Movie.count
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
    @moviecount = Movie.count
    erb :person
  end

  get '/movie/:movie_id' do |movie_id|
    @movie = Movie[moviedb_id: movie_id]
    @title = @movie.title
    @actors = Movie[moviedb_id: movie_id].crew
    @moviecount = Movie.count
    erb :episode
  end

  get '/episode/:episode' do |episode|
    @movie = Movie[episode: episode]
    @title = @movie.title
    @actors = Movie[episode: episode].crew
    @moviecount = Movie.count
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
