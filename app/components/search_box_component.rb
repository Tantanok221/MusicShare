# frozen_string_literal: true

class SearchBoxComponent < ViewComponent::Base
    def initialize(form_path:, search_param: :search_by_name)
        @form_path = form_path
        @search_param = search_param
    end
end
