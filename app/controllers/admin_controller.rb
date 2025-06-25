class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def home
    if params[:search_by_name].present?
      @artists = Artist.where("name LIKE ?", "%#{params[:search_by_name]}%")
    else
      @artists = Artist.all
    end
  end

  def artist
    @artist = Artist.find(params[:id])
  end

  def album_details_admin
    @album = Album.includes(:songs, :artists).find(params[:id])
    @artist = @album&.artists&.first
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Album not found"
    redirect_to admin_albums_path
  end

  def create_song
    @album = Album.find(params[:album_id])
    @song = @album.songs.build(song_params)

    if @song.save
      redirect_to album_details_admin_path(@album), notice: 'Song was successfully created.'
    else
      redirect_to album_details_admin_path(@album), alert: 'Error creating song: ' + @song.errors.full_messages.join(', ')
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_home_path, alert: 'Album not found.'
  end

  def destroy_song
    @song = Song.find(params[:id])
    @album = @song.album

    if @song.destroy
      redirect_to album_details_admin_path(@album), notice: 'Song was successfully deleted.'
    else
      redirect_to album_details_admin_path(@album), alert: 'Error deleting song.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_home_path, alert: 'Song not found.'
  end

  def song_params
    params.require(:song).permit(:title, :album_id)
  end

  # Add your ensure_admin method here if it's not defined elsewhere
  def ensure_admin
    redirect_to root_path unless current_user&.admin?
  end
end