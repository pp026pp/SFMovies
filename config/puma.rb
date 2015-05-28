workers Integer(ENV['WEB_CONCURRENCY'] || 2)
max_threads_count = Integer(ENV['MAX_THREADS'] || 25)
min_threads_count = Integer(ENV['MIN_THREADS'] || 10)
threads min_threads_count, max_threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  require 'prefix_trie'
  ActiveRecord::Base.establish_connection

  Redis.connect

  # initialize the trie
  movie_names = []
  Movie.all.each do |movie|
    movie_names << movie.title
  end

  $movie_names_trie = PrefixTrie.new movie_names
end
