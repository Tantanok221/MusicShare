require 'faker'

# Clear existing data to avoid duplicates when reseeding
# Delete in correct order to respect foreign key constraints
PlaylistSongMapping.delete_all
Playlist.delete_all
Review.delete_all
SongArtistMapping.delete_all
Song.delete_all
AlbumExternalLink.delete_all
AlbumGenreMapping.delete_all
AlbumArtistMapping.delete_all
Album.delete_all
Artist.delete_all
Genre.delete_all
User.delete_all

# Create users for reviews
users = 5.times.map do
  User.create!(
    username: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "test123",
    role: "user",
    bio: Faker::Lorem.paragraph(sentence_count: 2),
    created_at: Time.now,
    updated_at: Time.now
  )
end

# Create genres
genres = [ "Pop", "Rock", "Hip-Hop", "Jazz", "Electronic" ].map do |genre_name|
  Genre.create!(genre_name: genre_name)
end

# Create artists
artists = 5.times.map do
  Artist.create!(
    name: Faker::Music.band,
    bio: Faker::Lorem.paragraph(sentence_count: 2),
    profile_image_url: Faker::Avatar.image,
    created_at: Time.now
  )
end

# Create albums and associate with artists + genres
albums = 10.times.map do
  album = Album.create!(
    name: Faker::Music.album,
    album_image_url: Faker::LoremFlickr.image(size: "300x300", search_terms: [ 'music' ]),
    rating: rand(1.0..5.0),
    release_date: Faker::Date.backward(days: 1000),
    created_at: Time.now,
    updated_at: Time.now
  )

  # Link to 1-2 random artists
  artists.sample(2).each do |artist|
    AlbumArtistMapping.create!(album_id: album.id, artist_id: artist.id)
  end

  # Link to 1-3 random genres
  genres.sample(2).each do |genre|
    AlbumGenreMapping.create!(album_id: album.id, genre_id: genre.id)
  end

  # Create external links for the album
  [
    { platform: 'spotify', base_url: 'https://open.spotify.com/album/' },
    { platform: 'youtube', base_url: 'https://www.youtube.com/playlist?list=' },
    { platform: 'apple_music', base_url: 'https://music.apple.com/album/' }
  ].each do |link_data|
    # 50% chance to have each platform link
    if rand < 0.5
      platform_id = SecureRandom.alphanumeric(22)
      AlbumExternalLink.create!(
        album: album,
        platform: link_data[:platform],
        url: link_data[:base_url] + platform_id,
        created_at: Time.now,
        updated_at: Time.now
      )
    end
  end

  album
end

# Create songs for each album
songs = albums.flat_map do |album|
  4.times.map do
    Song.create!(
      album_id: album.id,
      title: Faker::Music::RockBand.song,
      popularity_score: rand(0.0..100.0).round(2),
      created_at: Time.now,
      updated_at: Time.now
    )
  end
end

# Link each song to the same artists as their album
songs.each do |song|
  album_artist_ids = AlbumArtistMapping.where(album_id: song.album_id).pluck(:artist_id)

  album_artist_ids.each do |artist_id|
    SongArtistMapping.create!(
      song_id: song.id,
      artist_id: artist_id
    )
  end
end

# Create reviews for some albums by random users
albums.sample(7).each do |album|
  2.times do
    Review.create!(
      user_id: users.sample.id,
      album_id: album.id,
      rating: rand(1.0..5.0),
      comment: Faker::Lorem.sentence(word_count: 10),
      created_at: Time.now
    )
  end
end

users.each do |user|
  rand(1..2).times do
    playlist = Playlist.create!(
      user_id: user.id,
      playlist_name: "#{Faker::Music.genre} Vibes",
      bio: Faker::Lorem.paragraph(sentence_count: 2),
      category: [ "Chill", "Workout", "Focus", "Party", "Mood" ].sample,
      created_at: Time.now
    )

    # Add 3-5 random songs to each playlist
    songs.sample(rand(3..5)).each do |song|
      PlaylistSongMapping.create!(
        playlist_id: playlist.id,
        song_id: song.id
      )
    end
  end
end

User.create!(
  username: "admin",
  email: "admin@admin.com",
  password: Rails.application.credentials.admin_password,
  role: "admin",
  created_at: Time.now,
)

puts "🔑 Admin password: #{Rails.application.credentials.admin_password}"
puts "✅ Seeded users, artists, albums, genres, songs, song-artist mappings, and reviews!"
puts "✅ Also seeded playlists and playlist-song mappings!"
puts "✅ Added external links for albums (Spotify, YouTube, Apple Music)!"
