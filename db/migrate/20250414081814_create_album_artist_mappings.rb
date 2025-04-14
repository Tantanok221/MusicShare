class CreateAlbumArtistMappings < ActiveRecord::Migration[8.0]
  def change
    create_table :album_artist_mappings do |t|
      t.references :album, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
