class Review < ApplicationRecord
  belongs_to :user
  belongs_to :album

  after_create :update_album_rating

  def update_album_rating
    album.update(rating: album.reviews.average(:rating))
  end
end
