class Album < ApplicationRecord
  has_many :songs, dependent: :destroy
  has_many :album_artist_mappings, dependent: :destroy
  has_many :artists, through: :album_artist_mappings

  has_many :album_genre_mappings, dependent: :destroy
  has_many :genres, through: :album_genre_mappings

  def self.filter_by_names_with(name)
    where("name like ?", "#{name}%")
  end

  scope :highest_rated, -> {
    order(rating: :desc)
  }

  scope :with_associations, -> {
    includes(:album_artist_mappings, :artists, :album_genre_mappings, :genres)
  }
end
