class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_song, only: [ :edit, :update, :destroy ]

  def edit
  end

  def update
    if @song.update(song_params)
      redirect_to admin_artist_path(@song.artists.first.id), notice: "Song updated successfully."
    else
      render :edit
    end
  end

  def destroy
    artist_id = @song.artists.first.id
    @song.destroy
    redirect_to admin_artist_path(artist_id), notice: "Song deleted successfully."
  end

  private

  def set_song
    @song = Song.find(params[:id])
  end

  def song_params
    params.require(:song).permit(:title)
  end
end
