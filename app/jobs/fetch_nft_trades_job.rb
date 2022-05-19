class FetchNftTradesJob < ApplicationJob
  queue_as :daily_job

  def perform
    slugs = ENV["NFT_SLUGS"].split(",")
    Nft.where(opensea_slug: slugs).each do |nft|
      FetchSingleNftTradesJob.perform_later(nft)
      sleep 1
    end
  end
end