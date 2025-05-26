class ArtistsController < ApplicationController
  def update
    @artist = Artist.find(params[:id])
    if @artist.update(artist_params)
      redirect_to admin_artist_path(@artist.id), notice: "Artist updated successfully"
    else
      render :edit
    end
  end


  def edit
    @artist = Artist.find(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :bio, :profile_image_url)
  end
end
