class HoldingRankSnapShotView < ApplicationRecord
  belongs_to :holding_rank_snap_shot

  default_scope { order(tokens_count: :desc) }
end
