class PlaylistsController < ApplicationController
  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user_id = current_user.id

    if @playlist.save
      redirect_to playlist_details_path(@playlist.id)
      puts "Playlist created successfully"
    else
      redirect_to root_path
      puts "Failed to create playlist"
    end
  end

  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
    redirect_to root_path
  end

  def playlist_params
    params.permit(:playlist_name)
  end
end
