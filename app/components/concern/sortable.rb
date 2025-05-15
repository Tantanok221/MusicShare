module Sortable
  extend ActiveSupport::Concern

  def sort_by_options
    {
      "title" => "Title",
      "rating" => "Rating",
      "year" => "Year",
      "artist" => "Artist"
    }
  end
end
