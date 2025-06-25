class RecommendationService
  def initialize(user)
    @user = user
  end

  def recommendations(limit = 4)
    return fallback_recommendations(limit) if user_new_or_inactive?

    recommended_albums = []
    remaining_limit = limit

    # Get content-based recommendations first
    content_based = content_based_recommendations(remaining_limit)
    recommended_albums.concat(content_based)
    remaining_limit -= content_based.length

    # Fill remaining with trending albums if needed
    if remaining_limit > 0
      trending = trending_recommendations(remaining_limit, exclude: recommended_albums.map(&:id))
      recommended_albums.concat(trending)
    end

    recommended_albums.take(limit)
  end

  private

  attr_reader :user

  def user_new_or_inactive?
    return true unless user
    
    # Consider user inactive if they have no playlists, reviews, or recent album views
    user.playlists.empty? && 
    user.reviews.empty? && 
    user.user_behavior_logs.where(action: 'view_album').where('created_at > ?', 30.days.ago).empty?
  end

  def fallback_recommendations(limit)
    # For new users, show trending albums (highest rated recent albums)
    Album.with_associations
         .joins(:reviews)
         .where('albums.created_at > ?', 6.months.ago)
         .group('albums.id')
         .order(Arel.sql('AVG(reviews.rating) DESC, COUNT(reviews.id) DESC'))
         .limit(limit)
  end

  def content_based_recommendations(limit)
    return [] if limit <= 0

    preferred_genres = extract_preferred_genres
    preferred_artists = extract_preferred_artists
    
    return [] if preferred_genres.empty? && preferred_artists.empty?

    # Find albums by preferred artists or in preferred genres
    albums = Album.with_associations
                  .joins('LEFT JOIN album_genre_mappings ON albums.id = album_genre_mappings.album_id')
                  .joins('LEFT JOIN album_artist_mappings ON albums.id = album_artist_mappings.album_id')
                  .where('album_genre_mappings.genre_id IN (?) OR album_artist_mappings.artist_id IN (?)', 
                         preferred_genres, preferred_artists)
                  .where.not(id: already_interacted_album_ids)
                  .group('albums.id')
                  .order('albums.rating DESC NULLS LAST, albums.created_at DESC')
                  .limit(limit)

    albums.to_a
  end

  def trending_recommendations(limit, exclude: [])
    return [] if limit <= 0

    Album.with_associations
         .where.not(id: exclude)
         .highest_rated
         .limit(limit)
  end

  def extract_preferred_genres
    # Get genres from user's playlists and highly rated reviews
    playlist_genres = user.playlists
                          .joins(songs: { album: :genres })
                          .select('genres.id')
                          .group('genres.id')
                          .order(Arel.sql('COUNT(*) DESC'))
                          .limit(5)
                          .pluck('genres.id')

    review_genres = user.reviews
                        .where('reviews.rating >= ?', 4.0)
                        .joins(album: :genres)
                        .select('genres.id')
                        .group('genres.id')
                        .order(Arel.sql('AVG(reviews.rating) DESC'))
                        .limit(5)
                        .pluck('genres.id')

    (playlist_genres + review_genres).uniq
  end

  def extract_preferred_artists
    # Get artists from user's playlists and highly rated reviews
    playlist_artists = user.playlists
                           .joins(songs: { album: :artists })
                           .select('artists.id')
                           .group('artists.id')
                           .order(Arel.sql('COUNT(*) DESC'))
                           .limit(5)
                           .pluck('artists.id')

    review_artists = user.reviews
                         .where('reviews.rating >= ?', 4.0)
                         .joins(album: :artists)
                         .select('artists.id')
                         .group('artists.id')
                         .order(Arel.sql('AVG(reviews.rating) DESC'))
                         .limit(5)
                         .pluck('artists.id')

    (playlist_artists + review_artists).uniq
  end

  def already_interacted_album_ids
    # Albums user has already reviewed or has songs in playlists
    reviewed_ids = user.reviews.pluck(:album_id)
    playlist_album_ids = user.playlists
                             .joins(:songs)
                             .select('songs.album_id')
                             .distinct
                             .pluck('songs.album_id')

    (reviewed_ids + playlist_album_ids).uniq
  end
end