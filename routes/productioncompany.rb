require 'sinatra'

# Routes for production companies.
class MovieingOn < Sinatra::Base
  get '/studios' do
    @title = "Our production companies"
    @header = 'Here are the various production companies we have covered:'
    productioncompanies = Hash.new(0)
    Productioncompany.all.each do |studio|
      productioncompanies[studio.name] = studio.movies.count
    end
    @productioncompanies = productioncompanies.sort_by { |_key, value | value }.reverse
    erb :countstudios
  end

  get '/studio/:studio' do |studio|
    @movies = Movie.select_all(:movies).join_table(:inner, :movie_productioncompany, :movie_id => :id).join(Productioncompany.where{Sequel.like(:name, studio)}, :id => :productioncompany_id).all
    @moviecount = Movie.count
    @title = studio
    erb :movielist
  end
end
