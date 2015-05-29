class Api::V1::MoviesController < ApplicationController
  def autocomplete
    query = params[:query]
    @movie_names = $movie_names_trie.top_searches query
  end

  def search
    @movie = Movie.find_by_title params[:title]
    if @movie
      $movie_names_trie.add_frequency @movie.title, 1
    else
      render json: {}, status: :not_found
    end
  end
end
