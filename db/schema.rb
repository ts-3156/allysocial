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

ActiveRecord::Schema.define(version: 2021_01_15_143559) do

  create_table "agents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_agents_on_created_at"
    t.index ["user_id"], name: "index_agents_on_user_id", unique: true
  end

  create_table "ahoy_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "authorized", null: false
    t.text "access_token", null: false
    t.text "access_secret", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_credentials_on_created_at"
    t.index ["user_id"], name: "index_credentials_on_user_id", unique: true
  end

  create_table "followers_chunks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "followers_snapshot_id", null: false
    t.bigint "previous_cursor"
    t.bigint "next_cursor"
    t.json "uids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_chunks_on_created_at"
    t.index ["followers_snapshot_id"], name: "index_followers_chunks_on_followers_snapshot_id"
  end

  create_table "followers_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.integer "users_count"
    t.json "job"
    t.json "description"
    t.json "location"
    t.json "url"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_followers_insights_on_user_snapshot_id", unique: true
  end

  create_table "followers_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_followers_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_followers_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "friends_chunks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "friends_snapshot_id", null: false
    t.bigint "previous_cursor"
    t.bigint "next_cursor"
    t.json "uids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_chunks_on_created_at"
    t.index ["friends_snapshot_id"], name: "index_friends_chunks_on_friends_snapshot_id"
  end

  create_table "friends_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.integer "users_count"
    t.json "job"
    t.json "description"
    t.json "location"
    t.json "url"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_friends_insights_on_user_snapshot_id", unique: true
  end

  create_table "friends_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_friends_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_friends_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "mutual_friends_chunks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "mutual_friends_snapshot_id", null: false
    t.json "uids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_mutual_friends_chunks_on_created_at"
    t.index ["mutual_friends_snapshot_id"], name: "index_mutual_friends_chunks_on_mutual_friends_snapshot_id"
  end

  create_table "mutual_friends_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.integer "users_count"
    t.json "job"
    t.json "description"
    t.json "location"
    t.json "url"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_mutual_friends_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_mutual_friends_insights_on_user_snapshot_id", unique: true
  end

  create_table "mutual_friends_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_mutual_friends_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_mutual_friends_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "one_sided_followers_chunks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "one_sided_followers_snapshot_id", null: false
    t.json "uids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_followers_chunks_on_created_at"
    t.index ["one_sided_followers_snapshot_id"], name: "index_one_sided_followers_chunks_on_snapshot_id"
  end

  create_table "one_sided_followers_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.integer "users_count"
    t.json "job"
    t.json "description"
    t.json "location"
    t.json "url"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_followers_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_one_sided_followers_insights_on_user_snapshot_id", unique: true
  end

  create_table "one_sided_followers_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_followers_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_one_sided_followers_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "one_sided_friends_chunks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "one_sided_friends_snapshot_id", null: false
    t.json "uids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_friends_chunks_on_created_at"
    t.index ["one_sided_friends_snapshot_id"], name: "index_one_sided_friends_chunks_on_one_sided_friends_snapshot_id"
  end

  create_table "one_sided_friends_insights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.integer "users_count"
    t.json "job"
    t.json "description"
    t.json "location"
    t.json "url"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_friends_insights_on_created_at"
    t.index ["user_snapshot_id"], name: "index_one_sided_friends_insights_on_user_snapshot_id", unique: true
  end

  create_table "one_sided_friends_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_snapshot_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_one_sided_friends_snapshots_on_created_at"
    t.index ["user_snapshot_id"], name: "index_one_sided_friends_snapshots_on_user_snapshot_id", unique: true
  end

  create_table "subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email"
    t.string "name"
    t.integer "price"
    t.decimal "tax_rate", precision: 4, scale: 2
    t.string "stripe_checkout_session_id"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "trial_end_at"
    t.datetime "canceled_at"
    t.datetime "charge_failed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_subscriptions_on_created_at"
    t.index ["stripe_checkout_session_id"], name: "index_subscriptions_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id", unique: true
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "twitter_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "screen_name", null: false
    t.string "name", null: false
    t.integer "statuses_count", null: false
    t.integer "friends_count", null: false
    t.integer "followers_count", null: false
    t.integer "listed_count"
    t.integer "favourites_count"
    t.boolean "is_protected"
    t.boolean "is_verified"
    t.text "description"
    t.string "location"
    t.text "url"
    t.string "profile_image_url"
    t.string "profile_banner_url"
    t.datetime "account_created_at"
    t.bigint "status_id"
    t.text "status_text"
    t.integer "status_retweet_count"
    t.integer "status_favorite_count"
    t.json "status_photo_urls"
    t.datetime "status_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_twitter_users_on_created_at"
    t.index ["uid"], name: "index_twitter_users_on_uid", unique: true
  end

  create_table "user_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_user_snapshots_on_created_at"
    t.index ["uid"], name: "index_user_snapshots_on_uid"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "uid", null: false
    t.string "screen_name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
