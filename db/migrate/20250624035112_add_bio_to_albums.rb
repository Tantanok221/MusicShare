class AddBioToAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :bio, :text
  end
end
