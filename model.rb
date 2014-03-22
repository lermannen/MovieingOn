require 'sequel'

DB = Sequel.sqlite('./movieingon.db')

class Person < Sequel::Model(:persons)
  many_to_many :movies, :class => :Movie, :right_key => :movie_id, :join_table => :crew, :select=>[Sequel.expr(:movies).*, :crew__job]
end

class Movie < Sequel::Model
  many_to_many :crew, :class => :Person, :right_key => :person_id, :join_table => :crew, :select=>[Sequel.expr(:persons).*, :crew__job]
  many_to_many :productioncompanies, :join_table => :movie_productioncompany
  many_to_many :genre, :join_table => :movie_genre
end

class Productioncompany < Sequel::Model
  many_to_many :movie, :class => :Movie, :join_table => :movie_productioncompany
end

class Genre < Sequel::Model
  many_to_many :movie, :class => :Movie, :join_table => :movie_genre
end