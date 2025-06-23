module ApplicationHelper
  def admin_user?
    user_signed_in? && current_user.admin?
  end

  def platform_icon(platform_name)
    case platform_name
    when 'Spotify'
      # Spotify uses their brand green color
      { icon: 'spotify-logo', class: 'h-5 w-5 text-green-500', title: 'Listen on Spotify' }
    when 'Apple Music'
      # Apple Music uses Apple's brand color
      { icon: 'apple-logo', class: 'h-5 w-5 text-gray-900', title: 'Listen on Apple Music' }
    when 'YouTube Music'
      # YouTube uses their brand red color
      { icon: 'youtube-logo', class: 'h-5 w-5 text-red-600', title: 'Listen on YouTube Music' }
    else
      # Generic link icon for other platforms
      { icon: 'link', class: 'h-5 w-5 text-gray-500', title: "Open #{platform_name}" }
    end
  end

  def streaming_links(album)
    # Filter out Last.fm links and return only streaming platforms
    album.album_external_links.reject { |link| link.platform == 'Last.fm' }
  end
end
