class PageController < ApplicationController
  def index
    @albums = RecommendationService.new(current_user).recommendations(8)
  end

  def playlist_details
    @playlist = Playlist.find(params[:id])
  end
  def search
    @albums = Album.with_associations
                   .search_by(params[:search_by_name], search_col: params[:search_col])
                   .filter_by_genre(params[:filter_by_genre])
                   .filter_by_rating(params[:filter_by_rating])
                   .order_by(params[:sort_by])
  end

  def playlist_index
  end

  def profile
    @user = User.find_by(username: params[:username])
    @reviews = @user.reviews.includes(:album).order(created_at: :desc)
  end

  def album_details
    @album = Album.with_associations.find(params[:id])
    
    # Track album view for logged in users
    if user_signed_in?
      UserBehaviorLog.create!(
        user: current_user,
        album: @album,
        action: 'view_album'
      )
    end
  end
end
