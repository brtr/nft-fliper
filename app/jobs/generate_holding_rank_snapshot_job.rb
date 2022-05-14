class GenerateHoldingRankSnapshotJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.yesterday)
    snap_shot = HoldingRankSnapShot.where(event_date: date).first_or_create

    HoldingRankSnapShotView.transaction do
      data = NftOwnerService.get_target_owners_rank
      data.each do |d|
        view = snap_shot.holding_rank_snap_shot_views.where(nft_id: d[:nft_id]).first_or_create
        view.tokens_count = d[:tokens_count]
        view.owners_count = d[:owners_count]
        view.update(d[:nft].as_json)
      end
    end
  end
end