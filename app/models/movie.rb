class Movie < ActiveRecord::Base
  has_many :filmed_ats
  has_many :locations, through: :filmed_ats

  def self.find_by_title title
    movie_json = $redis.get "movie:#{title}"
    if movie_json.nil?
      movie = Movie.find_by title: title
      $redis.set "movie:#{movie.title}", movie.to_json
    else
      movie = Movie.new(JSON.load movie_json)
    end
    movie
  end
end
