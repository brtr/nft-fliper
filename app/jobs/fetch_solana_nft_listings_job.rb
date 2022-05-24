require 'open-uri'

class FetchSolanaNftListingsJob < ApplicationJob
  queue_as :daily_job

  def perform
    Nft.where.not(chain_id: 1).each do |nft|
      url = "https://api.solanart.io/get_nft?collection=#{nft.slug}&page=0&limit=40&order=price-ASC&min=0&max=99999&search=&listed=true&fits=all&bid=all&cache=3"
      response = URI.open(url).read
      if response
        data = JSON.parse(response)
        $redis.set("#{nft.slug}_listings", data["items"].to_json) if data["items"].any?
      end

      sleep 1
    end
  end
end