require 'net/http'
require 'json'

class LastfmImportService
  BASE_URL = 'http://ws.audioscrobbler.com/2.0/'
  
  def initialize
    @api_key = ENV['LASTFM_API_KEY'] || raise('LASTFM_API_KEY environment variable is required')
    @imported_artists = {}
    @imported_genres = {}
  end

  def import_top_albums(limit = 50)
    puts "🎵 Fetching top #{limit} albums from Last.fm..."
    
    # Get top albums from Last.fm
    albums_data = fetch_top_albums(limit)
    
    albums_data.each_with_index do |album_data, index|
      puts "📀 Processing album #{index + 1}/#{limit}: #{album_data['name']} by #{album_data['artist']['name']}"
      
      begin
        process_album(album_data)
      rescue => e
        puts "   ❌ Error processing album: #{e.message}"
        next
      end
    end
  end

  private

  def fetch_top_albums(limit)
    # Use a different method that works better with the API
    url = build_url('tag.gettopalbums', {
      'api_key' => @api_key,
      'format' => 'json',
      'tag' => 'rock',
      'limit' => limit
    })
    
    puts "   🔗 API URL: #{url}"
    response = make_api_request(url)
    response.dig('albums', 'album') || []
  end

  def fetch_album_info(artist_name, album_name)
    url = build_url('album.getinfo', {
      'api_key' => @api_key,
      'format' => 'json',
      'artist' => artist_name,
      'album' => album_name
    })
    
    response = make_api_request(url)
    response['album']
  end

  def fetch_artist_info(artist_name)
    url = build_url('artist.getinfo', {
      'api_key' => @api_key,
      'format' => 'json',
      'artist' => artist_name
    })
    
    response = make_api_request(url)
    response['artist']
  end

  def process_album(album_data)
    artist_name = album_data['artist']['name']
    album_name = album_data['name']
    
    # Get detailed album info
    detailed_album = fetch_album_info(artist_name, album_name)
    return unless detailed_album
    
    # Process artist first
    artist = process_artist(artist_name)
    return unless artist
    
    # Process genres from tags
    genres = process_tags(detailed_album['tags'])
    
    # Create album
    album = create_album(detailed_album, artist, genres)
    
    # Process songs if available
    if detailed_album['tracks'] && detailed_album['tracks']['track']
      process_songs(detailed_album['tracks']['track'], album, artist)
    end
    
    puts "   ✅ Successfully imported: #{album_name}"
  end

  def process_artist(artist_name)
    # Check if already processed
    return @imported_artists[artist_name] if @imported_artists[artist_name]
    
    # Check if exists in database
    existing_artist = Artist.find_by(name: artist_name)
    if existing_artist
      @imported_artists[artist_name] = existing_artist
      return existing_artist
    end
    
    # Fetch artist info
    artist_info = fetch_artist_info(artist_name)
    return nil unless artist_info
    
    # Create artist
    artist = Artist.create!(
      name: artist_name,
      bio: extract_bio(artist_info),
      profile_image_url: extract_image_url(artist_info['image'])
    )
    
    @imported_artists[artist_name] = artist
    artist
  end

  def process_tags(tags_data)
    return [] unless tags_data && tags_data['tag']
    
    tags = tags_data['tag'].is_a?(Array) ? tags_data['tag'] : [tags_data['tag']]
    
    tags.map do |tag|
      genre_name = tag['name'].titleize
      
      # Check if already processed
      if @imported_genres[genre_name]
        @imported_genres[genre_name]
      else
        # Find or create genre - note: column is genre_name, not name
        genre = Genre.find_or_create_by(genre_name: genre_name)
        @imported_genres[genre_name] = genre
        genre
      end
    end.compact.take(3) # Limit to 3 genres per album
  end

  def create_album(album_data, artist, genres)
    album = Album.create!(
      name: album_data['name'],
      release_date: parse_release_date(album_data['releasedate']),
      rating: calculate_rating(album_data),
      album_image_url: extract_image_url(album_data['image']),
      bio: extract_album_bio(album_data)
    )
    
    # Create artist mapping
    AlbumArtistMapping.create!(album: album, artist: artist)
    
    # Create genre mappings
    genres.each do |genre|
      AlbumGenreMapping.create!(album: album, genre: genre)
    end
    
    # Create streaming platform links
    create_streaming_links(album, artist.name, album_data['name'])
    
    album
  end

  def process_songs(tracks_data, album, artist)
    tracks = tracks_data.is_a?(Array) ? tracks_data : [tracks_data]
    
    tracks.each_with_index do |track, index|
      song = Song.create!(
        title: track['name'],
        popularity_score: 0.0, # Default popularity score
        album: album
      )
      
      # Create song-artist mapping
      SongArtistMapping.create!(song: song, artist: artist)
    end
  end

  def build_url(method, params)
    query_string = params.map { |k, v| "#{k}=#{URI.encode_www_form_component(v)}" }.join('&')
    "#{BASE_URL}?method=#{method}&#{query_string}"
  end

  def make_api_request(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      JSON.parse(response.body)
    else
      puts "   ⚠️ API request failed: #{response.code} - #{response.message}"
      {}
    end
  rescue => e
    puts "   ⚠️ Network error: #{e.message}"
    {}
  end

  def extract_bio(artist_info)
    return nil unless artist_info && artist_info['bio']
    
    bio = artist_info['bio']['summary'] || artist_info['bio']['content']
    return nil unless bio
    
    # Clean up the bio text
    bio.gsub(/<[^>]*>/, '').strip.truncate(500)
  end

  def extract_album_bio(album_data)
    return nil unless album_data
    
    # Try to extract from wiki field (if available)
    if album_data['wiki'] && album_data['wiki']['summary']
      bio = album_data['wiki']['summary']
    elsif album_data['wiki'] && album_data['wiki']['content']
      bio = album_data['wiki']['content']
    else
      # Fall back to generating a bio from available metadata
      bio = generate_album_bio_from_metadata(album_data)
    end
    
    return nil unless bio && !bio.strip.empty?
    
    # Clean up the bio text and limit length
    bio.gsub(/<[^>]*>/, '').strip.truncate(800)
  end

  def generate_album_bio_from_metadata(album_data)
    return nil unless album_data['name'] && album_data['artist']
    
    parts = []
    
    # Add basic album info
    if album_data['releasedate'] && !album_data['releasedate'].strip.empty?
      release_year = parse_release_date(album_data['releasedate'])&.year
      parts << "Released in #{release_year}" if release_year
    end
    
    # Add listener/playcount info if significant
    if album_data['listeners'] && album_data['listeners'].to_i > 10000
      listeners = album_data['listeners'].to_i
      parts << "with over #{format_number(listeners)} listeners on Last.fm"
    end
    
    # Add genre information from tags
    if album_data['toptags'] && album_data['toptags']['tag']
      tags = album_data['toptags']['tag']
      tags = [tags] unless tags.is_a?(Array)
      genre_names = tags.first(3).map { |tag| tag['name'] }.join(', ')
      parts << "featuring #{genre_names} music" unless genre_names.empty?
    end
    
    return nil if parts.empty?
    
    "#{album_data['name']} by #{album_data['artist']['name'] || album_data['artist']}. #{parts.join(', ')}."
  end

  def format_number(num)
    case num
    when 1_000_000..Float::INFINITY
      "#{(num / 1_000_000.0).round(1)}M"
    when 1_000..999_999
      "#{(num / 1_000.0).round(1)}K"
    else
      num.to_s
    end
  end

  def extract_wiki_summary(wiki_data)
    return nil unless wiki_data && wiki_data['summary']
    
    wiki_data['summary'].gsub(/<[^>]*>/, '').strip.truncate(300)
  end

  def extract_image_url(images_data)
    return nil unless images_data && images_data.is_a?(Array)
    
    # Find the largest image
    large_image = images_data.find { |img| img['size'] == 'extralarge' } ||
                  images_data.find { |img| img['size'] == 'large' } ||
                  images_data.last
    
    large_image&.dig('#text')&.strip&.empty? ? nil : large_image&.dig('#text')
  end

  def parse_release_date(release_date_str)
    return nil unless release_date_str && !release_date_str.strip.empty?
    
    Date.parse(release_date_str.strip)
  rescue
    nil
  end

  def calculate_rating(album_data)
    # Use playcount and listeners to calculate a rating
    playcount = album_data['playcount'].to_i
    listeners = album_data['listeners'].to_i
    
    return 0 if listeners.zero?
    
    # Simple algorithm: average plays per listener, scaled to 1-5
    avg_plays = playcount.to_f / listeners
    rating = (avg_plays * 2).clamp(1, 5)
    rating.round(1)
  end

  def parse_duration(duration_str)
    return nil unless duration_str && !duration_str.to_s.empty?
    
    duration_str.to_i
  rescue
    nil
  end

  def create_streaming_links(album, artist_name, album_name)
    search_query = URI.encode_www_form_component("#{artist_name} #{album_name}")
    
    streaming_platforms = [
      {
        platform: 'Spotify',
        url: "https://open.spotify.com/search/#{search_query}"
      },
      {
        platform: 'Apple Music',
        url: "https://music.apple.com/search?term=#{search_query}"
      },
      {
        platform: 'YouTube Music',
        url: "https://music.youtube.com/search?q=#{search_query}"
      }
    ]
    
    streaming_platforms.each do |platform_data|
      AlbumExternalLink.create!(
        album: album,
        url: platform_data[:url],
        platform: platform_data[:platform]
      )
    end
  end
end