class FetchNftListingItemsJob < ApplicationJob
  queue_as :daily_job

  def perform
    50.times.each do
      data = $redis.rpop "nft_listing_items"
      next unless data
      data = JSON.parse data
      payload = data["payload"]
      nft = Nft.find_by opensea_slug: payload["collection"]["slug"]
      next unless nft
      item = payload["item"]
      if item["chain"]["name"] == "ethereum"
        decimal = 18
        name = item["permalink"].split("/").last
        price = payload["base_price"].to_f / 10 ** decimal
        nft.nft_listing_items.where(token_id: name, permalink: item["permalink"], base_price: price,
                                    listing_date: DateTime.parse(payload["listing_date"])).first_or_create
      end
    end
  end
end