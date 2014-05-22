require 'sinatra'

# Routes for genres.
class MovieingOn < Sinatra::Base
  get '/genres' do
    @title = "Our genres"
    @header = 'Here are the various genres we have covered:'
    genres = Hash.new(0)
    Genre.all.each do |genre|
      genres[genre.name] = genre.movies.count
    end
    @genres = genres.sort_by { |_key, value | value }.reverse
    erb :countgenres
  end

  get '/genre/:genre' do |genre|
    @movies = Movie.select_all(:movies).join_table(:inner, :movie_genre, :movie_id => :id).join(Genre.where{Sequel.like(:name, genre)}, :id => :genre_id).all
    @moviecount = Movie.count
    @title = genre
    erb :movielist
  end
end
