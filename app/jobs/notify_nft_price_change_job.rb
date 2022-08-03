require 'open-uri'

class NotifyNftPriceChangeJob < ApplicationJob
  queue_as :daily_job

  def perform
    result = []
    nfts = NotifyPriceChangeNftsService.get_nfts
    nfts.each do |nft|
      get_price(result, nft)

      sleep 5
    end

    puts result
    result.each_slice(10).each do |r|
      SlackService.send_notification(nil, r)
    end
  end

  def get_price(result, slug)
    begin
      nft = Nft.find_by(opensea_slug: slug)
      histories = nft.nft_histories.where("event_date >= ?", Date.today - 1.week)
      lowest_price = histories.min {|a, b| a.eth_floor_price <=> b.eth_floor_price}.eth_floor_price.to_f rescue 0

      if nft && nft.chain_id == 1
        url = "https://api.opensea.io/api/v1/collection/#{nft.opensea_slug}/stats"
        response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
        if response
          data = JSON.parse(response)
          new_price = data["stats"]["floor_price"].to_f rescue 0
          if new_price < lowest_price
            margin = new_price - lowest_price
            roi = lowest_price == 0 ? 0 : margin / lowest_price
            result.push(fall_price_blocks(slug, lowest_price, new_price, roi))
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
            result.push(fall_price_blocks(slug, lowest_price, new_price, roi))
          end
        end
      end
    rescue => e
      puts "#{slug} error at #{Time.now}"
      puts e
    end
  end

  def fall_price_blocks(slug, price, new_price, roi)
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*#{slug}* 在一周内价格跌破前低，上一次最低点为 #{price.round(3)}, 最新价格为 #{new_price.round(3)}, 下跌幅度为 #{(roi * 100).round(3)}%"
      }
    }
  end
end