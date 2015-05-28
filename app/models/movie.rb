class Movie < ActiveRecord::Base
  has_many :filmed_ats
  has_many :locations, through: :filmed_ats

  @@redis = Redis::Namespace.new("sf_movies:movie", :redis => Redis.new)

  def self.redis
    @@redis
  end

  def self.find_by_title title
    movie_json = redis.get "#{title}"
    if movie_json.nil?
      movie = Movie.find_by title: title
      $redis.set "#{movie.title}", movie.to_json
    else
      movie = Movie.new(JSON.load movie_json)
    end
    movie
  end
end
