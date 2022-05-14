class FetchSingleNftTradesJob < ApplicationJob
  queue_as :owner_daily_job

  def perform(nft_id)
    nft = Nft.find_by id: nft_id
    nft.sync_moralis_transfers
    nft.sync_moralis_trades
    NftOwnerService.holding_time_median(nft.id)
    NftHistoryService.get_data_from_trades(nft.id)
    NftOwnerService.fetch_purchase_histories(nft)
  end
end