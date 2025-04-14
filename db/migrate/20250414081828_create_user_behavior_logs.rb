class CreateUserBehaviorLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_behavior_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.string :action

      t.timestamps
    end
  end
end
