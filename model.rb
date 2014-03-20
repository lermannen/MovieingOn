require 'sequel'

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
  many_to_many :genre, :join_table => :movie_genre
end

class Productioncompany < Sequel::Model
  many_to_many :movie, :class => :Movie, :join_table => :movie_productioncompany
end

class Genre < Sequel::Model
  many_to_many :movie, :class => :Movie, :join_table => :movie_genre
end