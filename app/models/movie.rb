class Movie < ActiveRecord::Base
  has_many :filmed_ats
  has_many :locations, through: :filmed_ats
  accepts_nested_attributes_for :locations

  def self.redis
    @@redis ||= Redis::Namespace.new(
      "sf_movies:movies",
      :redis => Redis.new(url: URI.parse(ENV["REDISTOGO_URL"]))
    )
  end

  def self.find_by_title title
    movie_json = redis.get "#{title}"
    if movie_json.nil?
      movie = Movie.find_by title: title
      movie_json = movie.to_json(methods: :locations_attributes)
      redis.set "#{movie.title}", movie_json
      redis.expire "#{movie.title}", 1.day.seconds
    else
      movie = Movie.new
      movie.from_json(movie_json)
    end
    movie
  end

  def locations_attributes
    locations = self.locations
    locations.each do |location|
      location.id = nil
    end
    locations
  end
end
