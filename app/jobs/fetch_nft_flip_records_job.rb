class FetchNftFlipRecordsJob < ApplicationJob
  queue_as :daily_job

  def perform
    Nft.where.not(opensea_slug: nil).each do |nft|
      FetchNftFlipDataByNftJob.perform_later(nft.opensea_slug)
    end
  end
end