class Playlist < ApplicationRecord
  belongs_to :user

  has_many :playlist_song_mappings
  has_many :songs, through: :playlist_song_mappings
end
