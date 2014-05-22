require 'sinatra'

class MovieingOn < Sinatra::Base
	get '/person/:person_id' do |person_id|
    @person = Person[moviedb_id: person_id]
    @title = @person.name
    @movies = Person[moviedb_id: person_id].movies
    @moviecount = Movie.count
    erb :person
  end

  get '/actors' do
    @people = get_top_list('actor')
    @title = 'Our Actors'
    @header = 'The following actors have acted more than one movie:'
    @moviecount = Movie.count
    erb :people
  end

  get '/directors' do
    @people = get_top_list('director')
    @title = 'Our directors'
    @header = 'The following directors have directed more than one movie:'
    @moviecount = Movie.count
    erb :people
  end

  get '/writers' do
    @people = get_top_list('writer')
    @title = 'Our writers'
    @header = 'The following writers have written more than one movie:'
    @moviecount = Movie.count
    erb :people
  end
end