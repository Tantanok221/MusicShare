class CreatePlaylistSongMappings < ActiveRecord::Migration[8.0]
  def change
    create_table :playlist_song_mappings do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true

      t.timestamps
    end
  end
end
