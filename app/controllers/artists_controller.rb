class ArtistsController < ApplicationController
  before_action :set_artist, only: [ :update, :destroy, :edit ]
  before_action :ensure_admin


  def create
    @artist = Artist.new(artist_params)
    if @artist.save
      redirect_to admin_artist_path(@artist.id), notice: "Artist created successfully"
    end
  end

  def new
    @artist = Artist.new
  end
  def update
    if @artist.update(artist_params)
      redirect_to admin_artist_path(@artist.id), notice: "Artist updated successfully"
    else
      render :edit
    end
  end


  def edit
  end

  def artist_params
    params.require(:artist).permit(:name, :bio, :profile_image_url)
  end

  def destroy
    @artist.destroy
    redirect_to admin_home_path, notice: "Artist deleted successfully"
  end

  private
  def set_artist
    @artist = Artist.find(params[:id])
  end
end
