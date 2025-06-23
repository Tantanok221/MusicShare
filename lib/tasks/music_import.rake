namespace :music do
  desc "Import music data from Last.fm API and update database"
  task import: :environment do
    puts "🎵 Starting music import from Last.fm..."
    
    # Clear existing data
    puts "🧹 Clearing existing database records..."
    clear_existing_data
    
    # Initialize Last.fm service
    lastfm_service = LastfmImportService.new
    
    # Import data
    puts "📡 Fetching data from Last.fm API..."
    lastfm_service.import_top_albums
    
    puts "✅ Music import completed successfully!"
    print_summary
  end

  desc "Clear all music data from database"
  task clear: :environment do
    puts "🧹 Clearing all music data..."
    clear_existing_data
    puts "✅ Database cleared!"
  end

  private

  def clear_existing_data
    # Clear in correct order to avoid foreign key constraints
    PlaylistSongMapping.destroy_all
    SongTagMapping.destroy_all
    SongArtistMapping.destroy_all
    AlbumArtistMapping.destroy_all
    AlbumGenreMapping.destroy_all
    AlbumExternalLink.destroy_all
    Review.destroy_all
    
    Song.destroy_all
    Album.destroy_all
    Artist.destroy_all
    Genre.destroy_all
    SongMetadataTag.destroy_all
    
    puts "   ✓ Cleared all music records"
  end

  def print_summary
    puts "\n📊 Import Summary:"
    puts "   Artists: #{Artist.count}"
    puts "   Albums: #{Album.count}" 
    puts "   Songs: #{Song.count}"
    puts "   Genres: #{Genre.count}"
  end
end