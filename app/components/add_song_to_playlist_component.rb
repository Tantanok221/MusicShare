# frozen_string_literal: true

class AddSongToPlaylistComponent < ViewComponent::Base
  def initialize(song:)
    @song = song
  end
end
