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
    
    # Track album view for logged in users (avoid duplicates within 5 minutes)
    if user_signed_in?
      existing_log = UserBehaviorLog.find_by(
        user: current_user,
        album: @album,
        action: 'view_album',
        created_at: 5.minutes.ago..Time.current
      )
      
      if existing_log.nil?
        begin
          log = UserBehaviorLog.create!(
            user: current_user,
            album: @album,
            action: 'view_album'
          )
          Rails.logger.info "✅ Tracked album view: User #{current_user.id} viewed Album #{@album.id}"
        rescue => e
          Rails.logger.error "❌ Failed to track album view: #{e.message}"
        end
      else
        Rails.logger.info "⏭️ Skipped duplicate album view: User #{current_user.id} viewed Album #{@album.id} recently"
      end
    else
      Rails.logger.info "🚫 Not tracking album view: User not signed in"
    end
  end
end
