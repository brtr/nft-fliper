class FetchNftTradesJob < ApplicationJob
  queue_as :daily_job

  def perform
    Nft.order(is_marked: :desc).each do |nft|
      FetchSingleNftTradesJob.perform_later(nft.id)
    end
  end
end