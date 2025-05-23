class PlaylistSongsController < ApplicationController
  def create
    @song = Song.find(params[:song_id])
    params[:playlist_ids]&.each do |playlist_id|
      playlist = current_user.playlists.find(playlist_id)
      playlist.songs << @song unless playlist.songs.include?(@song)
    end
    refresh_or_redirect_to album_details_path(@song.album)
  end
  def destroy

    @song = Song.find(params[:id])
    @playlist = Playlist.find(params[:playlist_id])
    @playlist.songs.delete(@song)
    redirect_to playlist_details_path(@playlist.id)
  end

  private

end
