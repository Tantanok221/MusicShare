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
    @artist = Artist.find(params[:id])
    @albums = Album.all
    @albums = Album.includes(:songs).all
  end
end
