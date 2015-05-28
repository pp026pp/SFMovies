# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'set'

raw_table = CSV.table('db/data.csv')
movies_set = Set.new
locations_set = Set.new

raw_table.each do |row|
  row[:title] = row[:title].to_s.strip
  if movies_set.include? row[:title]
    movie = Movie.find_by(title: row[:title])
  else
    movie = Movie.new
    movie.title = row[:title]
    movie.release_year = DateTime.new row[:release_year]
    movie.fun_fact = row[:fun_facts]
    movie.production_company = row[:production_company]
    movie.distributor = row[:distributor]
    movie.director = row[:director]
    movie.writer = row[:writer]
    movie.actor1 = row[:actor_1]
    movie.actor2 = row[:actor_2]
    movie.actor3 = row[:actor_3]
    movie.save!

    movies_set.add movie.title
  end

  if locations_set.include? row[:locations].to_s
    location = Location.find_by(name: row[:locations])
  else
    location = Location.new
    location.name = row[:locations];
    location.save!

    locations_set.add location.name
  end

  filmed_at = FilmedAt.new
  filmed_at.movie_id = movie.id
  filmed_at.location_id = location.id
  filmed_at.save!
end
