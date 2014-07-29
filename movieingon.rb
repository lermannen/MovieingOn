require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'sinatra/base'
require 'sequel'

require_relative 'lib/model'
require_relative 'routes/routes'

# Base class for the MovieingOne application.
class MovieingOn < Sinatra::Base

  def get_top_list(job)
    persons = Hash.new { |h, k| h[k] = [] }

    Person.all.each do |p|
      movie_list = p.movies_dataset.where(job: job).all
      persons[movie_list.count] << {
        name: "<a href=\"person\\#{p.moviedb_id}\">#{p.name}</a>",
        movies: movie_list.map { |m| "<a href=\"movie\\#{m.moviedb_id}\">#{m.title}</a>" }.sort.join(', ')
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
      .group_and_count(:p__name, :p__moviedb_id).where(job: job).having{count(:*){} >= max_count}.all
      .map { |person| "<a href=\"person\\#{person[:moviedb_id]}\">#{person[:name]}</a>" }.sort.join(', ')
  end

  run! if app_file == $PROGRAM_NAME # If we run using 'ruby movieingon.rb'
end
