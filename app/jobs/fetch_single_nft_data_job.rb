class FetchSingleNftDataJob < ApplicationJob
  queue_as :default

  def perform(nft_id, date=Date.yesterday)
    nft = Nft.find nft_id
    nft.sync_opensea_stats
    sleep 2
    FetchSingleNftTradesJob.perform_now(nft.id)
    sleep 2
    nft.fetch_owners(date: date) if nft.total_owners.size < nft.total_supply.to_i * 0.5
    FetchOwnersDataJob.perform_now(nft.id)
    sleep 2
    NftOwnerService.get_target_owners_ratio(nft.id)
    sleep 2
    NftOwnerService.get_target_owners_trades(nft.id)
  end
end