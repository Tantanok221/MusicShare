class SongMetadataTag < ApplicationRecord
  has_many :song_tag_mappings
  has_many :song, through: :song_tag_mappings
end
