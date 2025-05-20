# frozen_string_literal: true

class UserListComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user

    if current_user.present?
      @playlists = current_user.playlists.limit(4)
    end
  end
end
