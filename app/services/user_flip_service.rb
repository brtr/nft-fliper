require 'open-uri'

class UserFlipService
  class << self
    def add_address(address)
      user = UserAddress.where(address: address).first_or_create
      puts "开始拉取交易数据"
      fetch_solana_trades(user)
      fetch_eth_trades(user)
      puts "交易数据拉取完成"
    end

    def get_flip_records(address)
      result = []

      trades = UserTrade.joins(:user_address).where(user_addresses: {address: address}).order(trade_time: :desc)
      trades.group_by{|t| [t.collection, t.token_address]}.each do |k, v|
        next if v.size < 2
        v.each do |trade|
          next unless trade.from_address.downcase == address.downcase
          last_trade = v.select{|x| x.to_address.downcase == address.downcase && x.trade_time < trade.trade_time}.first
          next unless last_trade
          revenue = trade.price - last_trade.price
          roi = (revenue / last_trade.price * 100).round(2)
          result << {
            collection: trade.collection,
            token_address: trade.token_address,
            from_address: last_trade.from_address,
            to_address: trade.to_address,
            fliper_address: address,
            sold: trade.price,
            bought: last_trade.price,
            revenue: revenue,
            roi: roi,
            sold_time: trade.trade_time,
            bought_time: last_trade.trade_time,
            gap: humanize_gap(trade.trade_time - last_trade.trade_time),
            chain: trade.token_address !~ /\D/ ? 'eth' : 'solana'
          }
        end
      end

      result
    end

    def humanize_gap(gap)
      gap = gap.to_f
      if gap < 86400
        hours = gap / 3600
        "#{I18n.t('duration.hours', count: hours.round(2))}"
      else
        days = (gap / 86400).to_i
        hours = (gap - days * 86400) / 3600
        "#{I18n.t('duration.days', count: days)} #{I18n.t('duration.hours', count: hours.round(2))}"
      end
    end

    def fetch_solana_trades(user)
      begin
        times = 0
        while true
          offset = times * 500
          response = URI.open("https://api-mainnet.magiceden.dev/v2/wallets/#{user.address}/activities?offset=#{offset}&limit=500").read
          if response
            data = JSON.parse(response)
            break if data.size < 1
            data.each do |d|
              next if d["type"].in?(["list", "delist", "bid", "cancelBid"])
              user.user_trades.where(
                collection: d["collection"],
                token_address: d["tokenMint"],
                from_address: d["seller"],
                to_address: d["buyer"],
                price: d["price"],
                txid: d["signature"],
                trade_time: Time.at(d["blockTime"]),
              ).first_or_create
            end
          end

          times += 1
          sleep 1
        end
      rescue => e
        puts "Fetch solana trades error: #{e.message}"
      end
    end

    def fetch_eth_trades(user, cursor: nil)
      begin
        url = "https://api.opensea.io/api/v1/events?event_type=successful&account_address=#{user.address}"
        url += "&cursor=#{cursor}" if cursor

        response = URI.open(url, {"X-API-KEY" => ENV["OPENSEA_API_KEY"]}).read
        if response
          data = JSON.parse(response)
          data["asset_events"].each do |event|
            asset = event["asset"]
            next if asset.nil? || asset["asset_contract"]["schema_name"] != "ERC721"
            price = event["total_price"].to_f / 10 ** event["payment_token"]["decimals"].to_i
            user.user_trades.where(
              collection: asset["collection"]["slug"],
              token_address: asset["token_id"],
              from_address: event["seller"]["address"],
              to_address: event["winner_account"]["address"],
              price: price,
              txid: event["transaction"]["transaction_hash"],
              trade_time: DateTime.parse(event["created_date"]),
            ).first_or_create
          end

          sleep 1
          fetch_eth_trades(user, cursor: data["next"]) if data["next"].present?
        end
      rescue => e
        puts "Fetch eth trades error: #{e.message}"
      end
    end
  end
end