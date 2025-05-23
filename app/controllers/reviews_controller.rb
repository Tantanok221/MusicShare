class ReviewsController < ApplicationController
  def create
    @review = Review.new(review_params)
    @review.user = current_user
    if @review.save
      redirect_to album_details_path(@review.album)
    else
      puts @review.errors.full_messages
      redirect_to album_details_path(@review.album)
    end
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :album_id)
  end
end
