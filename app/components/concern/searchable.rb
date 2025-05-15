module Searchable
  extend ActiveSupport::Concern

  def search_by_name
    {
      "title" => "Title",
      "artist" => "Artist"
    }
  end
end
