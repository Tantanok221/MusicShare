class CreateSongMetadataTags < ActiveRecord::Migration[8.0]
  def change
    create_table :song_metadata_tags do |t|
      t.string :tag_name

      t.timestamps
    end
  end
end
