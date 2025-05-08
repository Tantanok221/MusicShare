class Playlist < ApplicationRecord
  belongs_to :user

  has_many :playlist_song_mappings
  has_many :songs, through: :playlist_song_mappings

  def self.filter_by_id(id)
    where("user_id = ?", id)
  end

  scope :with_association, -> {
    includes(:playlist_song_mappings,:songs)
  }
end
