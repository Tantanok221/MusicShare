# frozen_string_literal: true

class SortByComponent < ViewComponent::Base
  include Sortable

  def initialize(selected: nil)
    @selected = selected
  end
end
