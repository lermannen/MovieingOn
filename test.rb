require 'sqlite3'
require 'sequel'
require 'themoviedb'

DB = Sequel.sqlite('./movieingon.db')

class Person < Sequel::Model(:persons)
  many_to_many :actor, :class => :Movie, :right_key => :movie_id, :join_table => :actors
  many_to_many :writer, :class => :Movie, :right_key => :movie_id, :join_table => :writers
  many_to_many :producer, :class => :Movie, :right_key => :movie_id, :join_table => :producers
  many_to_many :director, :class => :Movie, :right_key => :movie_id, :join_table => :directors
end

class Movie < Sequel::Model
  many_to_many :actor, :class => :Person, :right_key => :person_id, :join_table => :actors
  many_to_many :writer, :class => :Person, :right_key => :person_id, :join_table => :writers
  many_to_many :producer, :class => :Person, :right_key => :person_id, :join_table => :producers
  many_to_many :director, :class => :Person, :right_key => :person_id, :join_table => :directors
  many_to_many :productioncompanies, :join_table => :movie_productioncompany
end

class Productioncompany < Sequel::Model
  many_to_many :movie, :class => :Movie, :join_table => :movie_productioncompany
end

Tmdb::Api.key("f6343dcd785009de63b392bc4ac98e89")

  movie = Tmdb::Movie.detail(133)
  cast = Tmdb::Movie.casts(133)
  crew = Tmdb::Movie.crew(133)

p movie

Movie.all.each do |movie|
  p movie
  p movie.actor
  p movie.writer
  p movie.producer
  p movie.director
  p movie.productioncompanies
  movie.productioncompanies.each do |a|
    puts a.name
  end
end
