class CreatePlaylists < ActiveRecord::Migration[8.0]
  def change
    create_table :playlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :playlist_name
      t.string :category

      t.timestamps
    end
  end
end
