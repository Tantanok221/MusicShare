module Filterable
  extend ActiveSupport::Concern

  def filter_by_rating
    {
      "1" => "More then 1",
      "2" => "More then 2",
      "3" => "More then 3",
      "4" => "More then 4",
      "5" => "More then 5"
    }
  end

  def filter_by_genre
    # Psuedo Example for now
    {
      "Rock" => "Rock",
      "Pop" => "Pop",
      "Jazz" => "Jazz",
      "Blues" => "Blues"
    }
  end
end
