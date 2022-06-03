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

ActiveRecord::Schema.define(version: 2022_06_03_071411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analysis_nft_holders", force: :cascade do |t|
    t.string "token_name"
    t.string "token_address"
    t.string "holder_address"
    t.decimal "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["holder_address"], name: "index_analysis_nft_holders_on_holder_address"
    t.index ["token_address", "holder_address"], name: "index_analysis_nft_holders_on_token_and_holder_address", unique: true
    t.index ["token_address"], name: "index_analysis_nft_holders_on_token_address"
  end

  create_table "analysis_token_holders", force: :cascade do |t|
    t.string "token_name"
    t.string "token_address"
    t.string "holder_address"
    t.decimal "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["holder_address"], name: "index_analysis_token_holders_on_holder_address"
    t.index ["token_address", "holder_address"], name: "index_analysis_token_holders_on_token_and_holder_address", unique: true
    t.index ["token_address"], name: "index_analysis_token_holders_on_token_address"
  end

  create_table "fetch_data_logs", force: :cascade do |t|
    t.integer "fetch_type"
    t.string "source"
    t.string "url"
    t.string "error_msgs"
    t.datetime "event_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "holding_rank_snap_shot_views", force: :cascade do |t|
    t.integer "holding_rank_snap_shot_id"
    t.integer "nft_id"
    t.integer "chain_id"
    t.integer "sales_24h"
    t.integer "tokens_count"
    t.integer "owners_count"
    t.string "name"
    t.string "slug"
    t.string "logo"
    t.string "address"
    t.string "opensea_url"
    t.decimal "total_supply"
    t.decimal "floor_cap"
    t.decimal "listed_ratio"
    t.decimal "variation"
    t.decimal "floor_price_24h"
    t.decimal "volume_24h"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "eth_floor_price_24h"
    t.decimal "eth_floor_cap"
    t.decimal "eth_volume_24h"
    t.decimal "eth_volume_rank"
    t.decimal "eth_volume_rank_24h"
    t.decimal "eth_volume_rank_3d"
    t.decimal "volume_rank_24h"
    t.decimal "volume_rank_3d"
    t.decimal "bchp"
    t.decimal "median"
    t.decimal "listed"
    t.decimal "bchp_24h"
    t.decimal "bchp_24h_change"
    t.decimal "bchp_12h"
    t.decimal "bchp_12h_change"
    t.decimal "bchp_6h"
    t.decimal "bchp_6h_change"
    t.index ["holding_rank_snap_shot_id", "nft_id"], name: "index_holding_rank_snap_shot_id_and_nft_id", unique: true
    t.index ["holding_rank_snap_shot_id"], name: "index_holding_rank_snap_shot_views_on_holding_rank_snap_shot_id"
  end

  create_table "holding_rank_snap_shots", force: :cascade do |t|
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_holding_rank_snap_shots_on_event_date"
  end

  create_table "nft_flip_records", force: :cascade do |t|
    t.integer "nft_id"
    t.string "slug"
    t.string "token_address"
    t.string "token_id"
    t.string "from_address"
    t.string "to_address"
    t.string "txid"
    t.decimal "sold"
    t.decimal "bought"
    t.decimal "revenue"
    t.decimal "roi"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "fliper_address"
    t.string "bought_coin"
    t.string "sold_coin"
    t.decimal "bought_usd"
    t.decimal "sold_usd"
    t.integer "gap"
    t.datetime "sold_time"
    t.datetime "bought_time"
    t.string "image"
    t.string "permalink"
    t.decimal "revenue_usd"
    t.decimal "roi_usd"
    t.index ["bought_coin"], name: "index_nft_flip_records_on_bought_coin"
    t.index ["fliper_address"], name: "index_nft_flip_records_on_fliper_address"
    t.index ["nft_id", "token_id"], name: "index_nft_flip_records_on_nft_id_and_token_id"
    t.index ["nft_id"], name: "index_nft_flip_records_on_nft_id"
    t.index ["slug"], name: "index_nft_flip_records_on_slug"
    t.index ["sold_coin"], name: "index_nft_flip_records_on_sold_coin"
    t.index ["token_address"], name: "index_nft_flip_records_on_token_address"
    t.index ["txid"], name: "index_nft_flip_records_on_txid"
  end

  create_table "nft_histories", force: :cascade do |t|
    t.integer "nft_id"
    t.integer "sales"
    t.decimal "floor_price"
    t.decimal "volume"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "floor_price_7d"
    t.integer "eth_volume_rank"
    t.decimal "eth_floor_price"
    t.decimal "eth_volume"
    t.decimal "bchp"
    t.decimal "median"
    t.decimal "bchp_12h"
    t.decimal "bchp_6h"
    t.index ["nft_id"], name: "index_nft_histories_on_nft_id"
  end

  create_table "nft_listing_items", force: :cascade do |t|
    t.integer "nft_id"
    t.integer "status", default: 0
    t.string "token_id"
    t.string "permalink"
    t.decimal "base_price"
    t.datetime "listing_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nft_id"], name: "index_nft_listing_items_on_nft_id"
    t.index ["status"], name: "index_nft_listing_items_on_status"
    t.index ["token_id"], name: "index_nft_listing_items_on_token_id"
  end

  create_table "nft_purchase_histories", force: :cascade do |t|
    t.integer "nft_id"
    t.integer "owner_id"
    t.integer "amount"
    t.date "purchase_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nft_id", "owner_id"], name: "index_nft_purchase_histories_on_nft_id_and_owner_id"
  end

  create_table "nft_snap_shot_views", force: :cascade do |t|
    t.integer "nft_snap_shot_id"
    t.integer "nft_id"
    t.integer "chain_id"
    t.integer "sales_24h"
    t.string "name"
    t.string "slug"
    t.string "logo"
    t.string "address"
    t.string "opensea_url"
    t.decimal "total_supply"
    t.decimal "floor_cap"
    t.decimal "listed_ratio"
    t.decimal "variation"
    t.decimal "floor_price_24h"
    t.decimal "volume_24h"
    t.decimal "eth_floor_price_24h"
    t.decimal "eth_floor_cap"
    t.decimal "eth_volume_24h"
    t.decimal "eth_volume_rank"
    t.decimal "eth_volume_rank_24h"
    t.decimal "eth_volume_rank_3d"
    t.decimal "volume_rank_24h"
    t.decimal "volume_rank_3d"
    t.decimal "bchp"
    t.decimal "median"
    t.decimal "listed"
    t.decimal "bchp_12h"
    t.decimal "bchp_12h_change"
    t.decimal "bchp_6h"
    t.decimal "bchp_6h_change"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nft_id"], name: "index_nft_snap_shot_views_on_nft_id"
    t.index ["nft_snap_shot_id"], name: "index_nft_snap_shot_views_on_nft_snap_shot_id"
  end

  create_table "nft_snap_shots", force: :cascade do |t|
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_date"], name: "index_nft_snap_shots_on_event_date"
  end

  create_table "nft_trades", force: :cascade do |t|
    t.integer "nft_id"
    t.string "buyer"
    t.string "seller"
    t.string "token_id"
    t.decimal "trade_price"
    t.datetime "trade_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "permalink"
    t.index ["nft_id"], name: "index_nft_trades_on_nft_id"
  end

  create_table "nft_transfers", force: :cascade do |t|
    t.integer "nft_id"
    t.string "from_address"
    t.string "to_address"
    t.string "block_number"
    t.string "block_hash"
    t.string "token_id"
    t.decimal "value"
    t.decimal "amount"
    t.datetime "block_timestamp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "nfts", force: :cascade do |t|
    t.integer "chain_id"
    t.string "name"
    t.string "symbol"
    t.string "slug"
    t.string "website"
    t.string "opensea_url"
    t.string "address"
    t.string "logo"
    t.decimal "total_supply"
    t.decimal "floor_cap"
    t.decimal "listed_ratio"
    t.decimal "variation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_marked", default: false
    t.decimal "eth_floor_cap"
    t.string "opensea_slug"
    t.integer "user_id"
    t.decimal "listed"
    t.decimal "total_volume"
    t.boolean "sync_trades", default: false
    t.index ["sync_trades"], name: "index_nfts_on_sync_trades"
  end

  create_table "owner_nfts", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "nft_id"
    t.integer "amount"
    t.string "token_ids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "event_date"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_owner_nfts_on_deleted_at"
    t.index ["event_date"], name: "index_owner_nfts_on_event_date"
    t.index ["nft_id", "event_date"], name: "index_owner_nfts_on_nft_id_and_event_date"
    t.index ["nft_id"], name: "index_owner_nfts_on_nft_id"
    t.index ["owner_id", "nft_id", "event_date"], name: "index_owner_nfts_on_owner_id_and_nft_id_and_event_date"
    t.index ["owner_id", "nft_id"], name: "index_owner_nfts_on_owner_id_and_nft_id"
    t.index ["owner_id"], name: "index_owner_nfts_on_owner_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "target_nft_owner_histories", force: :cascade do |t|
    t.integer "nft_id"
    t.integer "n_type"
    t.string "data"
    t.date "event_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nft_id", "event_date", "n_type"], name: "index_target_nft_owner_histories_on_nft_id_event_date_and_type", unique: true
    t.index ["nft_id"], name: "index_target_nft_owner_histories_on_nft_id"
  end

  create_table "user_addresses", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_trades", force: :cascade do |t|
    t.integer "user_address_id"
    t.string "collection"
    t.string "token_address"
    t.string "from_address"
    t.string "to_address"
    t.string "txid"
    t.decimal "price"
    t.datetime "trade_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collection"], name: "index_user_trades_on_collection"
    t.index ["token_address"], name: "index_user_trades_on_token_address"
    t.index ["user_address_id"], name: "index_user_trades_on_user_address_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "subscription_date"
  end

end
