class AddBioToUserAndPlaylist < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bio, :text
    add_column :playlists, :bio, :text
  end
end
