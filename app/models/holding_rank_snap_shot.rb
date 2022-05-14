class HoldingRankSnapShot < ApplicationRecord
  has_many :holding_rank_snap_shot_views, dependent: :destroy
end
