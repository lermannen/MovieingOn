require 'sinatra'

class MovieingOn < Sinatra::Base
	get '/years' do
	  @title = "Our years"
	  @header = 'Here are the various years we have covered:'
	  years = Hash.new(0)
	  Movie.all.each do |movie|
	    years[movie.year.to_s] += 1
	  end
	  @years = years.sort_by { |_key, value | value }.reverse
	  erb :countyears
	end

	get '/year/:year' do |year|
	  @movies = Movie.filter(year: year).all
	  @moviecount = Movie.count
	  @title = year
	  erb :movielist
	end
end