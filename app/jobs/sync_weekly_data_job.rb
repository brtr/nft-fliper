class SyncWeeklyDataJob < ApplicationJob
  queue_as :default

  def perform(slug)
    nft = Nft.find_by opensea_slug: slug
    nft.sync_opensea_trades(start_at: Time.now - 1.week)
    nft.get_histories_from_trades
  end
end