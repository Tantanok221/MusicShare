class PlaylistController < ApplicationController
  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user_id = current_user.id

    if @playlist.save
      redirect_to list_path(@playlist.id)
      puts "Playlist created successfully"
    else
      redirect_to root_path
      puts "Failed to create playlist"
    end
  end

  def add_album_to_playlist
    @playlist = Playlist.find(params[:id])
    @album = Album.find(params[:album_id])
    @playlist.songs << @album.songs
  end

  def add_song_to_playlist
    @playlist = Playlist.find(params[:id])
    @song = Song.find(params[:song_id])
    @playlist.songs << @song
  end

  def playlist_params
    params.permit(:playlist_name)
  end
end
