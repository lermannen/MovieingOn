require 'sinatra'

# Routes for genres.
class MovieingOn < Sinatra::Base
  get '/admin' do
    protected!
    @movies = Movie.all
    @title = 'Movies'
    @moviecount = Movie.count
    erb :admin
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
