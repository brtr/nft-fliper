class FetchNftsFromTransfersJob < ApplicationJob
  queue_as :daily_job

  def perform
    NftHistoryService.fetch_nfts_from_transfer("auto")
    Nft.where(name: nil).each do |nft|
      nft.sync_opensea_info("auto")
      nft.fetch_owners(date: Date.yesterday)
      FetchSingleNftDataJob.perform_later(nft.id)
    end
  end
end