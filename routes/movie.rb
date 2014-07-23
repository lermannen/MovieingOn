require 'sinatra'

class MovieingOn < Sinatra::Base
	get '/movies' do
    @movies = Movie.all
    @title = 'Movies'
    @moviecount = Movie.count
    erb :movie
  end

  get '/movie/:movie_id' do |movie_id|
    persons = Hash.new { |h, k| h[k] = [] }
    Person_info = Struct.new(:moviedb_id, :name)

    Movie[moviedb_id: movie_id].crew.each do |g|
      persons[Person_info.new(g.moviedb_id, g.name)] << g[:job]
    end

    @movie = Movie[moviedb_id: movie_id]
    @title = @movie.title
    @actors = persons.sort_by { |key, _value | key.name }
    @moviecount = Movie.count
    erb :episode
  end

  get '/episode/:episode' do |episode|
    persons = Hash.new { |h, k| h[k] = [] }
    Person_info = Struct.new(:moviedb_id, :name)

    Movie[episode: episode].crew.each do |g|
      persons[Person_info.new(g.moviedb_id, g.name)] << g[:job]
    end

    @movie = Movie[episode: episode]
    @title = @movie.title
    @actors = persons
    @moviecount = Movie.count
    erb :episode
  end

  get '/rated' do
    @movies = Movie.select_map([:movieingonrating, :title, :year, :poster_url, :moviedb_id])
      .sort.reverse
    @title = 'Our ratings'
    @header = 'Here are how we rated the movies we covered!'
    @moviecount = Movie.count
    erb :rated
  end
end