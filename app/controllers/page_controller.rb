class PageController < ApplicationController
  def index
    @albums = Album.with_associations.highest_rated.limit(4)
  end

  def search
    @albums = Album.with_associations
                   .filter_by_names_with(params[:search_by_name])
  end

  def user_modal
    render partial: 'page/shared/user_modal', layout: false
  end

end
