# frozen_string_literal: true

class ReviewlistComponent < ViewComponent::Base
  def initialize(reviews:)
    @reviews = reviews
  end
end
