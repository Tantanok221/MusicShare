class AdminController < ApplicationController
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
end
