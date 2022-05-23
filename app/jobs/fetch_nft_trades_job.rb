class FetchNftTradesJob < ApplicationJob
  queue_as :daily_job

  def perform
    Nft.where(sync_trades: true).each do |nft|
      FetchSingleNftTradesJob.perform_later(nft)
      sleep 1
    end
  end
end