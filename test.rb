require 'sqlite3'
require 'sequel'
require 'themoviedb'
require_relative 'model'

apa = Tmdb::Configuration.new
puts  apa.base_url
p apa.poster_sizes
p apa.profile_sizes
