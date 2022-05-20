class FetchNftListingItemsJob < ApplicationJob
  queue_as :daily_job

  def perform
    50.times.each do
      item = $redis.rpop "nft_listing_items"
      next unless item
      item = JSON.parse item
      payload = item["payload"]
      nft = Nft.find_by opensea_slug: payload["collection"]["slug"]
      next unless nft
      item = payload["item"]
      decimal = item["chain"]["name"] == "ethereum" ? 18 : 9
      price = payload["base_price"].to_f / 10 ** decimal
      nft.nft_listing_items.where(token_id: item["permalink"].split("/").last, permalink: item["permalink"], base_price: price,
                                  listing_date: DateTime.parse(payload["listing_date"])).first_or_create
    end
  end
end