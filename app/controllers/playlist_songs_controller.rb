class PlaylistSongsController < ApplicationController
  before_action :find_song, only: [ :destroy, :create ]
  def create
    params[:playlist_ids]&.each do |playlist_id|
      playlist = current_user.playlists.find(playlist_id)
      playlist.songs << @song unless playlist.songs.include?(@song)
    end
  end
  def destroy
    puts "destroy song"
    @playlist = Playlist.find(params[:playlist_id])
    @playlist.songs.delete(@song)
    redirect_to playlist_details_path(@playlist.id)
  end

  private
  def find_song
    @song = Song.find(params[:id])
  end
end
