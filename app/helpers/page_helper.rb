module PageHelper
  def default_params
    {
      sort:  params[:sort_by] || "albums.name",
      search_col:  params[:search_col]  || "albums.name",
      rating: params[:filter_by_rating] || "",
      genre: params[:filter_by_genre] || ""
    }
  end
end
