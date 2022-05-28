class FetchSingleNftTradesJob < ApplicationJob
  queue_as :single_job

  def perform(nft)
    nft.sync_opensea_trades
  end
end