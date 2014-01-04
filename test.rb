require 'sqlite3'
require 'sequel'
require 'themoviedb'
require_relative 'model'

actors = Hash.new{|h,k| h[k] = []}

Person.all.each do |a|
  if a.actor.count > 0
    actors[a.actor.count] << {:actor => a.name, :movies => a.actor.map { |m| m.title}.join(", ")}
  end
end

Array(actors.sort.reverse).each do |count, hash|
  puts count
  hash.each do |array|
    puts "#{array[:actor]} #{array[:movies]}"
  end
end
