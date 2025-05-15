# frozen_string_literal: true

class AlbumComponent < ViewComponent::Base
  def initialize(album:)
    @album = album
  end
end
