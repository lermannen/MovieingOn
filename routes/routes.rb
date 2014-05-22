require 'sinatra'
require_relative 'admin'
require_relative 'genre'
require_relative 'movie'
require_relative 'person'
require_relative 'productioncompany'
require_relative 'year'


# Routes for the application.
class MovieingOn < Sinatra::Base
  set :views, Proc.new { File.join(root, "../views") }
  set :public_folder, Proc.new { File.join(root, "../public") }

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', ENV['ADMIN_PASSWORD']]
    end
  end

  get '/' do
    @actor_max = job_max('actor')
    @actor = job_toplist('actor', @actor_max)

    @director_max = job_max('director')
    @director = job_toplist('director', @director_max)

    production_company_max = DB[:movie_productioncompany]
      .group_and_count(:productioncompany_id).max(:count)

    @production_company = DB[:movie_productioncompany___mpc]
      .join(:productioncompanies___p, id: :productioncompany_id)
      .group_and_count(:p__name, :p__moviedb_id)
      .having{count(:*){} >= production_company_max}
      .all
      .map { |production_company| "<a href=\"studio\\#{production_company[:name]}\">#{production_company[:name]}</a>" }.sort.join(', ')

    @production_company_max = production_company_max
    @year = Movie.group_and_count(:year).order(:count).last
    @top_rating = Movie.max(:movieingonrating)
    @top_rated = Movie.where(movieingonrating: @top_rating).all
    @low_rating = Movie.min(:movieingonrating)
    @low_rated = Movie.where(movieingonrating: @low_rating).all

    @actors = get_top_list('actor')
    @title = ''
    @moviecount = Movie.count

    erb :home
  end
end
