# frozen_string_literal: true

class UserListComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user

    # puts @current_user.inspect
    if current_user.present?
      @playlists = Playlist
                     .filter_by_id(current_user.id)
                     .limit(4)
    end
  end
end
