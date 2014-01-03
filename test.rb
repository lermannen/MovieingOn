require 'sqlite3'
require 'sequel'
require 'themoviedb'

DB = Sequel.sqlite('./moveingon.db')

Tmdb::Api.key("f6343dcd785009de63b392bc4ac98e89")
movie = Tmdb::Movie.detail(562)
cast = Tmdb::Movie.casts(562)
crew = Tmdb::Movie.crew(562)

puts movie.original_title
puts cast
puts crew

crew.each do |crewman|
  if crewman["department"] == "Writing" || crewman["job"] == "Producer"
    puts "#{crewman["name"]} is a #{crewman["job"]}"
  end
end
cast.each do |actor|
  puts "-#{actor["id"]}-"
end
