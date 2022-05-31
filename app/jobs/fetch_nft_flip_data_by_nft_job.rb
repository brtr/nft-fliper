class FetchNftFlipDataByNftJob < ApplicationJob
  queue_as :single_job

  def perform(slug, duration=1.hour)
    nft = Nft.find_by opensea_slug: slug
    NftHistoryService.fetch_flip_data_by_nft(nft: nft, start_at: Time.now - duration) if nft
  end
end