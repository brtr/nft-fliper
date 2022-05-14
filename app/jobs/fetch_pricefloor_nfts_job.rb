class FetchPricefloorNftsJob < ApplicationJob
  queue_as :daily_job

  def perform
    NftHistoryService.fetch_nfts_data
    NftHistoryService.generate_nfts_view
  end
end