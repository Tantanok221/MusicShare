class PlaylistSongMapping < ApplicationRecord
  belongs_to :playlist
  belongs_to :song
end
