require 'open-uri'

class UserFlipService
  class << self
    def add_address(address)
      user = UserAddress.where(address: address).first_or_create
      times = 0
      while true
        offset = times * 500
        response = URI.open("https://api-mainnet.magiceden.dev/v2/wallets/#{address}/activities?offset=#{offset}&limit=500").read
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
      end
    end

    def get_flip_records(address)
      result = []

      trades = UserTrade.joins(:user_address).where(user_addresses: {address: address}).order(trade_time: :desc)
      trades.group_by{|t| [t.collection, t.token_address]}.each do |k, v|
        next if v.size < 2
        v.each do |trade|
          next unless trade.from_address == address
          last_trade = v.select{|x| x.to_address == address && x.trade_time < trade.trade_time}.first
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
            gap: humanize_gap(trade.trade_time - last_trade.trade_time)
          }
        end
      end

      result
    end

    def humanize_gap(gap)
      gap = gap.to_f
      if gap < 86400
        hours = gap / 3600
        "#{hours.round(2)} 小时"
      else
        days = (gap / 86400).to_i
        hours = (gap - days * 86400) / 3600
        "#{days} 天 #{hours.round(2)} 小时"
      end
    end
  end
end