class Album < ApplicationRecord
  has_many :songs, dependent: :destroy
  has_many :album_artist_mappings, dependent: :destroy
  has_many :artists, through: :album_artist_mappings
  has_many :album_external_links, dependent: :destroy
  has_many :album_genre_mappings, dependent: :destroy
  has_many :genres, through: :album_genre_mappings
  has_many :reviews, dependent: :destroy

  def self.search_by(name, search_col: "albums.name")
    return all if name.blank?

    case search_col
    when "artists.name"
      joins(:artists)
        .where("artists.name LIKE ?", "%#{name}%")
    else
      where("#{search_col} LIKE ?", "%#{name}%")
    end
  end

  def self.filter_by_rating(rating)
    return all unless rating.present?
    where("rating >= ?", rating.to_f)
  end

  def self.filter_by_genre(genre_id)
    return all unless genre_id.present?
    joins(:genres).where(genres: { id: genre_id })
  end

  def self.order_by(sort_by)
    case sort_by
    when "artists.name"
      albums_with_first_artist =
        select("albums.*, MIN(artists.name) as first_artist_name")
        .joins(:artists)
        .group("albums.id")

      from("(#{albums_with_first_artist.to_sql}) as albums")
        .includes(:album_artist_mappings, :artists, :album_genre_mappings, :genres)
        .order("first_artist_name")
    else
      order(sort_by)
    end
  end

  scope :highest_rated, -> {
    order(rating: :desc)
  }

  scope :with_associations, -> {
    includes(:album_artist_mappings, :artists, :album_genre_mappings, :genres)
  }
end
