# frozen_string_literal: true

class FilterByComponent < ViewComponent::Base
  include Filterable

  def initialize(selected: nil, variant:)
    @selected = selected
    @variant = variant
  end
end
