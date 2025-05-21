# frozen_string_literal: true

class SongListComponent < ViewComponent::Base
  def initialize(songs)
    @songs = songs
  end

  private

  attr_reader :songs
end
