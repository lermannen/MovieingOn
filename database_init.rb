require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite('./movieingon.db')

DB.create_table(:persons) do
  primary_key :id
  Integer :moviedb_id, :null => false
  String :name, :null => false
end

DB.create_table(:productioncompanies) do
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
end

DB.create_table(:actors) do
  foreign_key :person_id, :persons, :null => false
  foreign_key :movie_id, :movies, :null => false
end

DB.create_table(:writers) do
  foreign_key :person_id, :persons, :null => false
  foreign_key :movie_id, :movies, :null => false
end

DB.create_table(:directors) do
  foreign_key :person_id, :persons, :null => false
  foreign_key :movie_id, :movies, :null => false
end

DB.create_table(:producers) do
  foreign_key :person_id, :persons, :null => false
  foreign_key :movie_id, :movies, :null => false
end

DB.create_table(:movie_productioncompany) do
  foreign_key :movie_id, :movies, :null => false
  foreign_key :productioncompany_id, :productioncompanies, :null => false
end
