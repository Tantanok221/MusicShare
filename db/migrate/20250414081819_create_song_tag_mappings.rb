class CreateSongTagMappings < ActiveRecord::Migration[8.0]
  def change
    create_table :song_tag_mappings do |t|
      t.references :song, null: false, foreign_key: true
      t.references :song_metadata_tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
