class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_album, only: [ :edit, :update, :destroy ]

  def edit
  end

  def update
    if @album.update(album_params)
      redirect_to admin_artist_path(@album.artists.first.id), notice: "Album updated successfully."
    else
      render :edit
    end
  end

  def destroy
    artist_id = @album.artists.first.id
    @album.destroy
    redirect_to admin_artist_path(artist_id), notice: "Album deleted successfully."
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:name, :album_image_url, :rating)
  end
end
