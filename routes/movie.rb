require 'sinatra'

class MovieingOn < Sinatra::Base
	get '/movies' do
    @movies = Movie.all
    @title = 'Movies'
    @moviecount = Movie.count
    erb :movie
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

  get '/rated' do
    @movies = Movie.select_map([:movieingonrating, :title, :year, :poster_url, :moviedb_id])
      .sort.reverse
    @title = 'Our ratings'
    @header = 'Here are how we rated the movies we covered!'
    @moviecount = Movie.count
    erb :rated
  end
end