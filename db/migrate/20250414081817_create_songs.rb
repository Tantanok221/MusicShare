class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.references :album, null: false, foreign_key: true
      t.string :title
      t.float :popularity_score

      t.timestamps
    end
  end
end
