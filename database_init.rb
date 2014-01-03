require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite('./movieingon.db')

DB.create_table(:person) do
  primary_key :id
  String :name, :null => false
end

DB.create_table(:production_company) do
  primary_key :id
  String :name, :null => false
end

DB.create_table(:movie) do
  primary_key :id
  Integer :year, :null => false
  String :title, :null => false
  String :imdburl, :null => false
  Float :movieingonrating, :null => false
  Float :imdbrating, :null => false
end

DB.create_table(:actors) do
  foreign_key :person_id, :person, :null => false
  foreign_key :movie_id, :movie, :null => false
end

DB.create_table(:writers) do
  foreign_key :person_id, :person, :null => false
  foreign_key :movie_id, :movie, :null => false
end

DB.create_table(:directors) do
  foreign_key :person_id, :person, :null => false
  foreign_key :movie_id, :movie, :null => false
end

DB.create_table(:producers) do
  foreign_key :person_id, :person, :null => false
  foreign_key :movie_id, :movie, :null => false
end

DB.create_table(:movie_production_company) do
  foreign_key :movie_id, :movie, :null => false
  foreign_key :production_company_id, :production_company, :null => false
end
