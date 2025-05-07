class Song < ApplicationRecord
  belongs_to :album
  has_many :song_tag_mappings
  has_many :song_metadata_tags, through: :song_tag_mappings

  has_many :playlist_song_mappings
  has_many :playlists, through: :playlist_song_mappings

  has_many :song_artist_mappings, dependent: :destroy
  has_many :artists, through: :song_artist_mappings
end
