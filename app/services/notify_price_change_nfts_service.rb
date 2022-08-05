require 'open-uri'

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

    def get_price_change_nfts
      result = []
      begin
        nfts = get_nfts

        nfts.each do |slug|
          nft = Nft.includes(:nft_histories).where(opensea_slug: slug).take
          next unless nft
          histories = nft.nft_histories.where("event_date >= ?", Date.today - 1.week)
          lowest_price = histories.min {|a, b| a.eth_floor_price <=> b.eth_floor_price}.eth_floor_price.to_f rescue 0

          if nft.chain_id == 1
            url = "https://api.opensea.io/api/v1/collection/#{nft.opensea_slug}/stats"
            response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
            if response
              data = JSON.parse(response)
              new_price = data["stats"]["floor_price"].to_f rescue 0
              if new_price < lowest_price
                margin = new_price - lowest_price
                roi = lowest_price == 0 ? 0 : margin / lowest_price
                result.push([slug, lowest_price, new_price, roi])
              end
            end
          else
            url = "https://api-mainnet.magiceden.dev/v2/collections/#{nft.slug}/stats"
            response = URI.open(url).read
            if response
              data = JSON.parse(response)
              new_price = data["floorPrice"] / 10 ** 9 rescue 0
              if new_price < lowest_price
                margin = new_price - lowest_price
                roi = lowest_price == 0 ? 0 : margin / lowest_price
                result.push([slug, lowest_price, new_price, roi])
              end
            end
          end
        end

        result
      rescue => e
        puts "Error at #{Time.now}"
        puts e
        result
      end
    end
  end
end