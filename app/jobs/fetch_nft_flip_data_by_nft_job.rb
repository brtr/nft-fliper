class FetchNftFlipDataByNftJob < ApplicationJob
  queue_as :daily_job

  def perform(slug)
    nft = Nft.find_by opensea_slug: slug
    NftHistoryService.fetch_flip_data_by_nft(nft: nft) if nft
  end
end