class RecommendationService
  def initialize(user)
    @user = user
    @logger = Rails.logger
  end

  def recommendations(limit = 4)
    @logger.info "🎵 Starting recommendation generation for #{user_display_name} (limit: #{limit})"
    
    if user_new_or_inactive?
      @logger.info "👤 User classified as NEW/INACTIVE - using fallback strategy"
      result = fallback_recommendations(limit)
      @logger.info "✅ Generated #{result.length} fallback recommendations: #{result.map(&:name).join(', ')}"
      return result
    end

    @logger.info "👤 User classified as ACTIVE - using personalized recommendations"
    recommended_albums = []
    remaining_limit = limit

    # Get content-based recommendations first
    @logger.info "🎯 Fetching content-based recommendations (limit: #{remaining_limit})"
    content_based = content_based_recommendations(remaining_limit)
    recommended_albums.concat(content_based)
    remaining_limit -= content_based.length
    @logger.info "📊 Content-based found #{content_based.length} albums, remaining slots: #{remaining_limit}"

    # Fill remaining with trending albums if needed
    if remaining_limit > 0
      @logger.info "🔥 Filling #{remaining_limit} remaining slots with trending albums"
      trending = trending_recommendations(remaining_limit, exclude: recommended_albums.map(&:id))
      recommended_albums.concat(trending)
      @logger.info "📊 Added #{trending.length} trending albums"
    end

    final_recommendations = recommended_albums.take(limit)
    @logger.info "✅ Final recommendations (#{final_recommendations.length}): #{final_recommendations.map(&:name).join(', ')}"
    final_recommendations
  end

  private

  attr_reader :user

  def user_display_name
    return "Guest User" unless user
    user.username || "User ##{user.id}"
  end

  def user_new_or_inactive?
    return true unless user
    
    playlist_count = user.playlists.count
    review_count = user.reviews.count
    recent_views = user.user_behavior_logs.where(action: 'view_album').where('created_at > ?', 30.days.ago).count
    
    @logger.info "📊 User activity analysis:"
    @logger.info "   - Playlists: #{playlist_count}"
    @logger.info "   - Reviews: #{review_count}" 
    @logger.info "   - Recent album views (30 days): #{recent_views}"
    
    is_inactive = playlist_count == 0 && review_count == 0 && recent_views == 0
    @logger.info "   - Status: #{is_inactive ? 'INACTIVE' : 'ACTIVE'}"
    
    is_inactive
  end

  def fallback_recommendations(limit)
    @logger.info "🔄 Executing fallback recommendation strategy"
    @logger.info "   - Looking for trending albums from last 6 months"
    
    albums = Album.with_associations
                  .order(:rating)
                  .limit(limit)
    
    @logger.info "   - Found #{albums.count} trending albums"
    albums.each_with_index do |album, index|
      @logger.info "     #{index + 1}. #{album.name} (Rating: #{album.rating&.round(2) || 'N/A'})"
    end
    
    albums
  end

  def content_based_recommendations(limit)
    return [] if limit <= 0

    @logger.info "🎯 Analyzing user preferences for content-based recommendations"
    
    preferred_genres = extract_preferred_genres
    preferred_artists = extract_preferred_artists
    
    @logger.info "🎨 User preference summary:"
    @logger.info "   - Preferred genres (#{preferred_genres.length}): #{preferred_genres.empty? ? 'None' : preferred_genres.join(', ')}"
    @logger.info "   - Preferred artists (#{preferred_artists.length}): #{preferred_artists.empty? ? 'None' : preferred_artists.join(', ')}"
    
    if preferred_genres.empty? && preferred_artists.empty?
      @logger.info "❌ No user preferences found - skipping content-based recommendations"
      return []
    end

    excluded_album_ids = already_interacted_album_ids
    @logger.info "🚫 Excluding #{excluded_album_ids.length} already interacted albums"

    # Find albums by preferred artists or in preferred genres
    @logger.info "🔍 Searching for albums matching user preferences..."
    albums = Album.with_associations
                  .joins('LEFT JOIN album_genre_mappings ON albums.id = album_genre_mappings.album_id')
                  .joins('LEFT JOIN album_artist_mappings ON albums.id = album_artist_mappings.album_id')
                  .where('album_genre_mappings.genre_id IN (?) OR album_artist_mappings.artist_id IN (?)', 
                         preferred_genres, preferred_artists)
                  .where.not(id: excluded_album_ids)
                  .group('albums.id')
                  .order('albums.rating DESC NULLS LAST, albums.created_at DESC')
                  .limit(limit)

    result = albums.to_a
    @logger.info "✨ Content-based recommendations found: #{result.length}"
    result.each_with_index do |album, index|
      @logger.info "     #{index + 1}. #{album.name} (Rating: #{album.rating&.round(2) || 'N/A'})"
    end
    
    result
  end

  def trending_recommendations(limit, exclude: [])
    return [] if limit <= 0

    @logger.info "🔥 Fetching trending recommendations (excluding #{exclude.length} albums)"
    
    albums = Album.with_associations
                  .where.not(id: exclude)
                  .highest_rated
                  .limit(limit)
    
    @logger.info "📈 Trending albums found: #{albums.count}"
    albums.each_with_index do |album, index|
      @logger.info "     #{index + 1}. #{album.name} (Rating: #{album.rating&.round(2) || 'N/A'})"
    end
    
    albums
  end

  def extract_preferred_genres
    @logger.info "🎵 Extracting preferred genres from user data (prioritizing: views > playlists > reviews)"
    
    # PRIORITY 1: Get genres from user's recent album views
    @logger.info "   👁️ Analyzing viewed album genres (last 30 days)..."
    begin
      viewed_genres = user.user_behavior_logs
                          .where(action: 'view_album')
                          .where('user_behavior_logs.created_at > ?', 30.days.ago)
                          .joins(album: :genres)
                          .select('genres.id, genres.genre_name')
                          .group('genres.id, genres.genre_name')
                          .order(Arel.sql('COUNT(*) DESC'))
                          .limit(8)
      
      viewed_genre_names = viewed_genres.pluck('genres.genre_name')
      viewed_genre_ids = viewed_genres.pluck('genres.id')
      @logger.info "     Found #{viewed_genre_ids.length} viewed genres: #{viewed_genre_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting viewed genres: #{e.message}"
      viewed_genre_ids = []
      viewed_genre_names = []
    end

    # PRIORITY 2: Get genres from user's playlists (if needed)
    @logger.info "   📋 Analyzing playlist genres..."
    begin
      playlist_genres = user.playlists
                            .joins(songs: { album: :genres })
                            .select('genres.id, genres.genre_name')
                            .group('genres.id, genres.genre_name')
                            .order(Arel.sql('COUNT(*) DESC'))
                            .limit(5)
      
      playlist_genre_names = playlist_genres.pluck('genres.genre_name')
      playlist_genre_ids = playlist_genres.pluck('genres.id')
      @logger.info "     Found #{playlist_genre_ids.length} playlist genres: #{playlist_genre_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting playlist genres: #{e.message}"
      playlist_genre_ids = []
      playlist_genre_names = []
    end

    # PRIORITY 3: Get genres from highly rated reviews (fallback)
    @logger.info "   ⭐ Analyzing high-rated review genres (4+ stars)..."
    begin
      review_genres = user.reviews
                          .where('reviews.rating >= ?', 4.0)
                          .joins(album: :genres)
                          .select('genres.id, genres.genre_name')
                          .group('genres.id, genres.genre_name')
                          .order(Arel.sql('AVG(reviews.rating) DESC'))
                          .limit(3)
      
      review_genre_names = review_genres.pluck('genres.genre_name')
      review_genre_ids = review_genres.pluck('genres.id')
      @logger.info "     Found #{review_genre_ids.length} review genres: #{review_genre_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting review genres: #{e.message}"
      review_genre_ids = []
      review_genre_names = []
    end

    # Combine with priority weighting (views first, then playlists, then reviews)
    combined_genre_ids = (viewed_genre_ids + playlist_genre_ids + review_genre_ids).uniq
    @logger.info "   ✅ Combined preferred genres: #{combined_genre_ids.length} unique genres"
    @logger.info "       Priority breakdown: #{viewed_genre_ids.length} from views, #{playlist_genre_ids.length} from playlists, #{review_genre_ids.length} from reviews"
    
    combined_genre_ids
  end

  def extract_preferred_artists
    @logger.info "🎤 Extracting preferred artists from user data (prioritizing: views > playlists > reviews)"
    
    # PRIORITY 1: Get artists from user's recent album views
    @logger.info "   👁️ Analyzing viewed album artists (last 30 days)..."
    begin
      viewed_artists = user.user_behavior_logs
                           .where(action: 'view_album')
                           .where('user_behavior_logs.created_at > ?', 30.days.ago)
                           .joins(album: :artists)
                           .select('artists.id, artists.name')
                           .group('artists.id, artists.name')
                           .order(Arel.sql('COUNT(*) DESC'))
                           .limit(8)
      
      viewed_artist_names = viewed_artists.pluck('artists.name')
      viewed_artist_ids = viewed_artists.pluck('artists.id')
      @logger.info "     Found #{viewed_artist_ids.length} viewed artists: #{viewed_artist_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting viewed artists: #{e.message}"
      viewed_artist_ids = []
      viewed_artist_names = []
    end

    # PRIORITY 2: Get artists from user's playlists (if needed)
    @logger.info "   📋 Analyzing playlist artists..."
    begin
      playlist_artists = user.playlists
                             .joins(songs: { album: :artists })
                             .select('artists.id, artists.name')
                             .group('artists.id, artists.name')
                             .order(Arel.sql('COUNT(*) DESC'))
                             .limit(5)
      
      playlist_artist_names = playlist_artists.pluck('artists.name')
      playlist_artist_ids = playlist_artists.pluck('artists.id')
      @logger.info "     Found #{playlist_artist_ids.length} playlist artists: #{playlist_artist_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting playlist artists: #{e.message}"
      playlist_artist_ids = []
      playlist_artist_names = []
    end

    # PRIORITY 3: Get artists from highly rated reviews (fallback)
    @logger.info "   ⭐ Analyzing high-rated review artists (4+ stars)..."
    begin
      review_artists = user.reviews
                           .where('reviews.rating >= ?', 4.0)
                           .joins(album: :artists)
                           .select('artists.id, artists.name')
                           .group('artists.id, artists.name')
                           .order(Arel.sql('AVG(reviews.rating) DESC'))
                           .limit(3)
      
      review_artist_names = review_artists.pluck('artists.name')
      review_artist_ids = review_artists.pluck('artists.id')
      @logger.info "     Found #{review_artist_ids.length} review artists: #{review_artist_names.join(', ')}"
    rescue => e
      @logger.warn "     Error extracting review artists: #{e.message}"
      review_artist_ids = []
      review_artist_names = []
    end

    # Combine with priority weighting (views first, then playlists, then reviews)
    combined_artist_ids = (viewed_artist_ids + playlist_artist_ids + review_artist_ids).uniq
    @logger.info "   ✅ Combined preferred artists: #{combined_artist_ids.length} unique artists"
    @logger.info "       Priority breakdown: #{viewed_artist_ids.length} from views, #{playlist_artist_ids.length} from playlists, #{review_artist_ids.length} from reviews"
    
    combined_artist_ids
  end

  def already_interacted_album_ids
    @logger.info "🚫 Identifying albums to exclude from recommendations"
    
    # Albums user has already reviewed
    reviewed_ids = user.reviews.pluck(:album_id)
    @logger.info "   📝 Reviewed albums: #{reviewed_ids.length}"
    
    # Albums that have songs in user's playlists
    playlist_album_ids = user.playlists
                             .joins(:songs)
                             .select('songs.album_id')
                             .distinct
                             .pluck('songs.album_id')
    @logger.info "   📋 Playlist albums: #{playlist_album_ids.length}"

    combined_ids = (reviewed_ids + playlist_album_ids).uniq
    @logger.info "   ✅ Total albums to exclude: #{combined_ids.length}"
    
    combined_ids
  end
end