class Movie < ActiveRecord::Base
  has_many :filmed_ats
  has_many :locations, through: :filmed_ats
end
