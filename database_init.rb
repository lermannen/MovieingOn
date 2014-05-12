require 'pg'
require 'sequel'

DB = Sequel.connect('postgres://akorling@localhost:5432/movieingon')

DB.create_table(:persons) do
  primary_key :id
  Integer :moviedb_id, :null => false
  String :name, :null => false
  String :profile_url
end

DB.create_table(:productioncompanies) do
  primary_key :id
  Integer :moviedb_id, :null => false
  String :name, :null => false
end

DB.create_table(:genres) do
  primary_key :id
  Integer :moviedb_id, :null => false
  String :name, :null => false
end

DB.create_table(:movies) do
  primary_key :id
  Integer :moviedb_id, :null => false
  Integer :year, :null => false
  String :title, :null => false
  String :imdburl, :null => false
  Float :movieingonrating, :null => false
  Float :imdbrating, :null => false
  Integer :episode, :null => false
  String :poster_url
end

DB.create_table(:crew) do
  foreign_key :person_id, :persons, :null => false
  foreign_key :movie_id, :movies, :null => false
  String :job, :null => false
end

DB.create_table(:movie_productioncompany) do
  foreign_key :movie_id, :movies, :null => false
  foreign_key :productioncompany_id, :productioncompanies, :null => false
end

DB.create_table(:movie_genre) do
  foreign_key :movie_id, :movies, :null => false
  foreign_key :genre_id, :genres, :null => false
end
