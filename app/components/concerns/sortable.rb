# frozen_string_literal: true

module Sortable
  extend ActiveSupport::Concern

  def sort_options
    {
      "albums.name" => "Title",
      "rating ASC" => "Rating",
      "created_at" => "Year",
      "artists.name" => "Artist"
    }
  end
end
