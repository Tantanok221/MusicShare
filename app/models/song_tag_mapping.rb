class SongTagMapping < ApplicationRecord
  belongs_to :song
  belongs_to :song_metadata_tag
end
