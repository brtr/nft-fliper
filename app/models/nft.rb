require 'open-uri'

class Nft < ApplicationRecord
  has_many :nft_trades, autosave: true
  has_many :nft_transfers, autosave: true
  has_many :nft_flip_records, autosave: true
  has_many :nft_listing_items, autosave: true

  validates :slug, uniqueness: true, allow_nil: true

  def sync_opensea_stats(mode="manual")
    return unless opensea_slug

    begin
      url = "https://api.opensea.io/api/v1/collection/#{opensea_slug}/stats"
      response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
      if response
        data = JSON.parse(response)
        result = data["stats"]
        #listed = NftHistoryService.fetch_listed_from_opensea(opensea_slug)
        self.update(total_supply: result["count"], total_volume: result["total_volume"], eth_floor_cap: result["market_cap"], variation: 0)
        h = nft_histories.where(event_date: Date.yesterday).first_or_create
        NftHistoryService.cal_bchp(self, h)
        h.update(eth_floor_price: result["floor_price"], eth_volume: result["one_day_volume"], sales: result["one_day_sales"])
      end
    rescue => e
      FetchDataLog.create(fetch_type: mode, source: "Sync Opensea Stats", url: url, error_msgs: e, event_time: DateTime.now)
      puts "Fetch opensea Error: #{name} can't sync stats"
    end
  end

  def sync_opensea_info(mode="manual")
    return unless address

    begin
      url = "https://api.opensea.io/api/v1/asset_contract/#{address}"
      response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
      if response
        data = JSON.parse(response)

        slug = data["collection"]["slug"]
        self.update(chain_id: 1, name: data["name"], slug: slug, opensea_slug: slug, logo: data["image_url"], opensea_url: "https://opensea.io/collection/#{slug}")
      end
    rescue => e
      FetchDataLog.create(fetch_type: mode, source: "Sync Opensea Info", url: url, error_msgs: e, event_time: DateTime.now)
      puts "Fetch opensea Error: #{name} can't sync info"
    end
  end

  def sync_opensea_trades(cursor: nil, mode: "manual", start_at: nil, end_at: nil)
    end_at ||= Time.now
    start_at ||= end_at.at_beginning_of_day

    url = "https://api.opensea.io/api/v1/events?collection_slug=#{opensea_slug}&event_type=successful&occurred_after=#{start_at.to_i}&occurred_before=#{end_at.to_i}"
    url += "&cursor=#{cursor}" if cursor
    begin
      response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
      if response
        data = JSON.parse(response)
        data["asset_events"].each do |event|
          asset = event["asset"]
          next if asset.nil?
          schema_name = asset["asset_contract"]["schema_name"]
          next if !["ERC721", "METAPLEX"].include?(schema_name)
          slug = asset["collection"]["slug"]
          if schema_name == "ERC721"
            token_id = asset["token_id"]
            price = event["total_price"].to_f / 10 ** event["payment_token"]["decimals"].to_i
          else
            token_id = asset["name"].split("#").last
            price = event["total_price"].to_f / 10 ** 9
          end

          nft_trades.where(token_id: token_id, trade_time: DateTime.parse(event["created_date"]), seller: event["seller"]["address"],
                          buyer: event["winner_account"]["address"], trade_price: price, permalink: asset["permalink"]).first_or_create
        end

        sleep 1
        sync_opensea_trades(cursor: data["next"], mode: mode, start_at: start_at, end_at: end_at) if data["next"].present?
      end
    rescue => e
      FetchDataLog.create(fetch_type: mode, source: "Fetch flip data", url: url, error_msgs: e, event_time: Time.now)
      puts "Fetch opensea Error: #{e}"
    end
  end

  class << self
    def add_new(opensea_slug, solanart_slug: nil, address: nil, chain: "solana", duration: 1.hour)
      chain_id = chain == "solana" ? 101 : 1

      if chain == "solana" && solanart_slug.nil?
        puts "You need to pass solanart slug!"
        return false
      end

      if chain == "eth" && address.nil?
        puts "You need to pass collection address!"
        return false
      end

      slug = solanart_slug || opensea_slug
      nft = Nft.create(chain_id: chain_id, slug: solanart_slug, opensea_slug: opensea_slug, address: address, sync_trades: true)
      FetchNftFlipDataByNftJob.perform_later(nft.opensea_slug, duration)
      puts "#{opensea_slug} 添加成功，开始抓取 flip data"
    end
  end
end
