class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :bio
      t.string :profile_image_url

      t.timestamps
    end
  end
end
