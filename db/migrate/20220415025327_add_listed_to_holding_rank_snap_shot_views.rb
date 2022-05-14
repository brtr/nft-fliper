class AddListedToHoldingRankSnapShotViews < ActiveRecord::Migration[6.1]
  def change
    add_column :holding_rank_snap_shot_views, :listed, :decimal
  end
end
