require 'themoviedb'
require 'set'

# Wrapper for themoviedb gem.
class TheMovieDB
  attr_reader :config

  def initialize
    @config = Tmdb::Configuration.new
    Tmdb::Api.key('f6343dcd785009de63b392bc4ac98e89')
  end

  def base_url
    config.base_url + 'w185'
  end

  def image_url(profile_path)
    "#{base_url}#{profile_path}" unless profile_path.nil?
  end

  def crew(movie_id)
    crew = Tmdb::Movie.crew(movie_id)
    s = Set.new
    crew.each do |crewman|
      path = image_url(crewman['profile_path'])
      c = Crewman.new(crewman['name'], crewman['id'], path)
      if crewman['department'] == 'Writing'
        c.job = :writer
      elsif crewman['job'] == 'Producer' || crewman['job'] == 'Director'
        c.job = crewman['job'].downcase.to_sym
      end
      s.add(c)
    end
    s
  end

  def actors(movie_id)
    actors = Tmdb::Movie.casts(movie_id)
    s = Set.new
    actors.each do |actor|
      path = image_url(actor['profile_path'])
      s.add(Crewman.new(actor['name'], actor['id'], path, :actor))
    end
    s
  end

  def movie_details(movie_id)
    Tmdb::Movie.detail(movie_id)
  end

  Crewman = Struct.new(:name, :id, :profile_path, :job) do

  end
end