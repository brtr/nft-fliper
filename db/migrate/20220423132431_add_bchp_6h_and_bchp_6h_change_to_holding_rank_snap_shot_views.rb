class AddBchp6hAndBchp6hChangeToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :bchp_6h, :decimal
    add_column :holding_rank_snap_shot_views, :bchp_6h_change, :decimal
  end
end
