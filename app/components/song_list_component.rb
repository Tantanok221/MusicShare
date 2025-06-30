# frozen_string_literal: true

class SongListComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(songs:, playlist:)
    @songs = songs
    @playlist = playlist
  end

  private

  attr_reader :songs
end
