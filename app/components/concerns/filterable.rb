module Filterable
  extend ActiveSupport::Concern

  def filter_by_rating
    {
      "1" => "1+ Stars",
      "2" => "2+ Stars",
      "3" => "3+ Stars",
      "4" => "4+ Stars",
      "4.5" => "4.5+ Stars"
    }
  end

  def filter_by_genre
    Genre.all.map { |genre| [ genre.id.to_s, genre.genre_name ] }.to_h
  end
end
