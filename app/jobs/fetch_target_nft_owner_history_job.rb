class FetchTargetNftOwnerHistoryJob < ApplicationJob
  queue_as :daily_job

  def perform
    Nft.all.each do |nft|
      NftOwnerService.get_target_owners_ratio(nft.id)
      sleep 2
      NftOwnerService.get_target_owners_trades(nft.id)
      sleep 2
    end
  end
end