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

ActiveRecord::Schema[7.0].define(version: 2023_06_30_112952) do
  create_table "daily_words", force: :cascade do |t|
    t.string "word"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "requester_id"
    t.integer "responder_id"
    t.boolean "accepted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.string "image_url"
    t.string "note"
    t.integer "user_id", null: false
    t.integer "daily_word_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_word_id"], name: "index_submissions_on_daily_word_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified"
    t.string "verification_token"
    t.datetime "verification_expiry"
    t.string "password_reset_token"
    t.datetime "password_reset_expiry"
    t.string "avatar_url"
    t.string "bio"
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token"
    t.index ["verification_token"], name: "index_users_on_verification_token"
  end

  add_foreign_key "submissions", "daily_words"
  add_foreign_key "submissions", "users"
end
