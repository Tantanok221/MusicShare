# frozen_string_literal: true

class RemoveSongFromPlaylistComponent < ViewComponent::Base
  def initialize(song:, playlist:)
    @song = song
    @playlist = playlist
  end
end
