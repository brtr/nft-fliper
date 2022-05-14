class GenerateNftSnapshotJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.yesterday)
    snap_shot = NftSnapShot.where(event_date: date).first_or_create

    NftSnapShotView.transaction do
      NftsView.all.each do |nft|
        view = snap_shot.nft_snap_shot_views.where(nft_id: nft.nft_id).first_or_create
        view.update(nft.as_json)
      end
    end
  end
end