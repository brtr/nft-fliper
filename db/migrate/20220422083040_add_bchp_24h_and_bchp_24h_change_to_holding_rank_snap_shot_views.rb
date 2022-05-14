class AddBchp24hAndBchp24hChangeToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :bchp_24h, :decimal
    add_column :holding_rank_snap_shot_views, :bchp_24h_change, :decimal
  end
end
