class NotifyPriceChangeNftsService
  class << self
    def add_nft(slug)
      $redis.hset("notify_price_change_nfts", slug, 1)
    end

    def del_nft(slug)
      $redis.hdel("notify_price_change_nfts", slug)
    end

    def get_nfts
      $redis.hkeys("notify_price_change_nfts")
    end
  end
end