# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  def search_by_name
    {
      "albums.name" => "Title",
      "artists.name" => "Artist"
    }
  end
end
