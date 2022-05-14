class CreateNftSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    create_table :nft_snap_shot_views do |t|
      t.integer :nft_snap_shot_id
      t.integer :nft_id
      t.integer :chain_id
      t.integer :sales_24h
      t.string :name
      t.string :slug
      t.string :logo
      t.string :address
      t.string :opensea_url
      t.decimal :total_supply
      t.decimal :floor_cap
      t.decimal :listed_ratio
      t.decimal :variation
      t.decimal :floor_price_24h
      t.decimal :volume_24h
      t.decimal :eth_floor_price_24h
      t.decimal :eth_floor_cap
      t.decimal :eth_volume_24h
      t.decimal :eth_volume_rank
      t.decimal :eth_volume_rank_24h
      t.decimal :eth_volume_rank_3d
      t.decimal :volume_rank_24h
      t.decimal :volume_rank_3d
      t.decimal :bchp
      t.decimal :median
      t.decimal :listed
      t.decimal :bchp_12h
      t.decimal :bchp_12h_change
      t.decimal :bchp_6h
      t.decimal :bchp_6h_change

      t.timestamps
    end

    add_index :nft_snap_shot_views, :nft_snap_shot_id
    add_index :nft_snap_shot_views, :nft_id
  end
end
