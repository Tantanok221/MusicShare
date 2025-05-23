class PlaylistAlbumsController < ApplicationController
  def create
    @album = Album.find(params[:album_id])

    # Loop through each selected playlist ID
    params[:playlist_ids]&.each do |playlist_id|
      playlist = current_user.playlists.find(playlist_id)
      playlist.songs << @album.songs
    end

    redirect_back(fallback_location: root_path, notice: "Album added to playlists")
  end
end
