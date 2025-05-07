# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_07_084049) do
  create_table "album_artist_mappings", force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_album_artist_mappings_on_album_id"
    t.index ["artist_id"], name: "index_album_artist_mappings_on_artist_id"
  end

  create_table "album_genre_mappings", force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_album_genre_mappings_on_album_id"
    t.index ["genre_id"], name: "index_album_genre_mappings_on_genre_id"
  end

  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.string "album_image_url"
    t.float "rating"
    t.datetime "release_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "bio"
    t.string "profile_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "genre_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlist_song_mappings", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "song_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_playlist_song_mappings_on_playlist_id"
    t.index ["song_id"], name: "index_playlist_song_mappings_on_song_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "playlist_name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "album_id", null: false
    t.float "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_reviews_on_album_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "song_artist_mappings", force: :cascade do |t|
    t.integer "song_id", null: false
    t.integer "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_song_artist_mappings_on_artist_id"
    t.index ["song_id"], name: "index_song_artist_mappings_on_song_id"
  end

  create_table "song_metadata_tags", force: :cascade do |t|
    t.string "tag_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "song_tag_mappings", force: :cascade do |t|
    t.integer "song_id", null: false
    t.integer "song_metadata_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_song_tag_mappings_on_song_id"
    t.index ["song_metadata_tag_id"], name: "index_song_tag_mappings_on_song_metadata_tag_id"
  end

  create_table "songs", force: :cascade do |t|
    t.integer "album_id", null: false
    t.string "title"
    t.float "popularity_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_songs_on_album_id"
  end

  create_table "user_behavior_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "song_id", null: false
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_user_behavior_logs_on_song_id"
    t.index ["user_id"], name: "index_user_behavior_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role", default: "user", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "album_artist_mappings", "albums"
  add_foreign_key "album_artist_mappings", "artists"
  add_foreign_key "album_genre_mappings", "albums"
  add_foreign_key "album_genre_mappings", "genres"
  add_foreign_key "playlist_song_mappings", "playlists"
  add_foreign_key "playlist_song_mappings", "songs"
  add_foreign_key "playlists", "users"
  add_foreign_key "reviews", "albums"
  add_foreign_key "reviews", "users"
  add_foreign_key "song_artist_mappings", "artists"
  add_foreign_key "song_artist_mappings", "songs"
  add_foreign_key "song_tag_mappings", "song_metadata_tags"
  add_foreign_key "song_tag_mappings", "songs"
  add_foreign_key "songs", "albums"
  add_foreign_key "user_behavior_logs", "songs"
  add_foreign_key "user_behavior_logs", "users"
end
