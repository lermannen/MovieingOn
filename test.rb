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
end

Movie.all.each do |movie|
  p movie
  p movie.actor
  p movie.writer
  p movie.producer
  p movie.director
end
Person.all.each do |person|
  p person
  p person.actor
  p person.writer
  p person.producer
end
