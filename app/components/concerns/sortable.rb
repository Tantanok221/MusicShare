# frozen_string_literal: true

module Sortable
  extend ActiveSupport::Concern

  def sort_options
    {
      "title" => "Title",
      "rating" => "Rating",
      "year" => "Year",
      "artist" => "Artist"
    }
  end
end
