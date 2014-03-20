require 'sequel'

Sequel.migration do
  up do
    create_table(:roles) do
      primary_key :id
      String :role_name, null: false
    end

    create_table(:person_movie) do
      foreign_key :person_id, :persons, null: false
      foreign_key :movie_id, :movies, null: false
      foreign_key :role, :roles, null: false
    end

    # Create roles
    actor = from(:roles).insert(role_name: 'Actor')
    writer = from(:roles).insert(role_name: 'Writer')
    producer = from(:roles).insert(role_name: 'Producer')
    director = from(:roles).insert(role_name: 'Director')

    # Migrate data

    # Drop old tables
  end
end
