class AddBchp12hAndBchp12hChangeToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :bchp_12h, :decimal
    add_column :holding_rank_snap_shot_views, :bchp_12h_change, :decimal
  end
end
