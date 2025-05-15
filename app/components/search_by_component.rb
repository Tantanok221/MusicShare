# frozen_string_literal: true

class SearchByComponent < ViewComponent::Base
  include Searchable

  def initialize(selected: nil)
    @selected = selected
  end
end
