class AddColumnsToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :eth_floor_price_24h, :decimal
    add_column :holding_rank_snap_shot_views, :eth_floor_cap, :decimal
    add_column :holding_rank_snap_shot_views, :eth_volume_24h, :decimal
    add_column :holding_rank_snap_shot_views, :eth_volume_rank, :decimal
    add_column :holding_rank_snap_shot_views, :eth_volume_rank_24h, :decimal
    add_column :holding_rank_snap_shot_views, :eth_volume_rank_3d, :decimal
    add_column :holding_rank_snap_shot_views, :volume_rank_24h, :decimal
    add_column :holding_rank_snap_shot_views, :volume_rank_3d, :decimal
  end
end
