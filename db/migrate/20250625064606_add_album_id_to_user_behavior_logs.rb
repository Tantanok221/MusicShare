class AddAlbumIdToUserBehaviorLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :user_behavior_logs, :album_id, :integer
    change_column_null :user_behavior_logs, :song_id, true
  end
end
