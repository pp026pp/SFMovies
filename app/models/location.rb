class Location < ActiveRecord::Base
  has_many :filmed_ats
  has_many :movies, through: :filmed_ats
end
