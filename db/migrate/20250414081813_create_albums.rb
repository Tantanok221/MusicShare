class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.string :name
      t.string :album_image_url
      t.float :rating
      t.datetime :release_date

      t.timestamps
    end
  end
end
