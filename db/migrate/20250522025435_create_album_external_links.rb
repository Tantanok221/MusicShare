class CreateAlbumExternalLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :album_external_links do |t|
      t.string :platform
      t.string :url
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
    add_index :album_external_links, :platform
  end
end
