class FetchOwnersDataJob < ApplicationJob
  queue_as :owner_daily_job

  def perform(nft_id)
    NftOwnerService.fetch_owners(nft_id: nft_id, mode: "auto")
  end
end