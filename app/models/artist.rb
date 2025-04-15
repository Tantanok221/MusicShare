class Artist < ApplicationRecord
  has_many :album_artist_mappings
  has_many :albums, through: :album_artist_mappings
  has_many :album_genre_mappings
  has_many :genres, through: :album_genre_mappings
end
