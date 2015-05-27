require 'prefix_trie'

movie_names = []
Movie.all.each do |movie|
  movie_names << movie.title
end

$movie_names_trie = PrefixTrie.new movie_names
