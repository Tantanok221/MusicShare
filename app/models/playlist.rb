class Playlist < ApplicationRecord
  belongs_to :user

  has_many :playlist_song_mappings, dependent: :destroy
  has_many :songs, through: :playlist_song_mappings

  def self.filter_by_id(id)
    where("user_id = ?", id)
  end
  validates :playlist_name, presence: true
  validates :user_id, presence: true

  scope :with_association, -> {
    includes(:playlist_song_mappings, :songs)
  }
end
