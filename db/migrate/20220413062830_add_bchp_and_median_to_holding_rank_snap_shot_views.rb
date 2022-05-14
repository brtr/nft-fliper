class AddBchpAndMedianToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :bchp, :decimal
    add_column :holding_rank_snap_shot_views, :median, :decimal
  end
end
