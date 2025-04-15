class Genre < ApplicationRecord
  has_many :album_genre_mappings
  has_many :albums, through: :album_genre_mappings
end
