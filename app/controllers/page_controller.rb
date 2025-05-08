class PageController < ApplicationController
  def index
    @albums = Album.with_associations

  end

  def search
    @albums = Album.with_associations
                   .filter_by_names_with(params[:search_by_name])
  end

end
