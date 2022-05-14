class CreateHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    create_table :holding_rank_snap_shot_views do |t|
      t.integer :holding_rank_snap_shot_id
      t.integer :nft_id
      t.integer :chain_id
      t.integer :sales_24h
      t.integer :tokens_count
      t.integer :owners_count
      t.string  :name
      t.string  :slug
      t.string  :logo
      t.string  :address
      t.string  :opensea_url
      t.decimal :total_supply
      t.decimal :floor_cap
      t.decimal :listed_ratio
      t.decimal :variation
      t.decimal :floor_price_24h
      t.decimal :volume_24h

      t.timestamps
    end

    add_index :holding_rank_snap_shot_views, :holding_rank_snap_shot_id
    add_index :holding_rank_snap_shot_views, [:holding_rank_snap_shot_id, :nft_id],
              unique: true,
              name: "index_holding_rank_snap_shot_id_and_nft_id"
  end
end
