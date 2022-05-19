class PriceChartService
  attr_reader :start_date, :end_date, :nft_id, :fliper_address, :slug

  def initialize(start_date: nil, end_date: nil, nft_id: nil, fliper_address: nil, slug: nil)
    @start_date = start_date
    @end_date = end_date || Date.today
    @nft_id = nft_id
    @fliper_address = fliper_address
    @slug = slug
  end

  def get_price_data
    result = {}
    NftHistory.where(event_date: [start_date..end_date], nft_id: nft_id).group_by(&:event_date).sort_by{|date, records| date}.each do |date, records|
      result.merge!({date => records.map{|x| {floor_price: x.eth_floor_price, volume: x.eth_volume, sales: x.sales, date: date}}})
    end

    result
  end

  def get_holding_data
    result = {}
    TargetNftOwnerHistory.holding.where(event_date: [start_date..end_date], nft_id: nft_id).group_by(&:event_date).sort_by{|date, records| date}.each do |date, records|
      h = NftHistory.where(nft_id: nft_id, event_date: date).first_or_create
      result.merge!({date => records.map{|x| {bch_count: x.data[:bch_count], floor_price: h.eth_floor_price, date: date}}})
    end
    result
  end

  def get_purchase_data
    result = {}
    TargetNftOwnerHistory.purchase.where(event_date: [start_date..end_date], nft_id: nft_id).group_by(&:event_date).sort_by{|date, records| date}.each do |date, records|
      result.merge!({date => records.map{|x| {bch_count: x.data[:bch_count], date: date}}})
    end
    result
  end

  def get_trade_data
    records = NftTrade.where(trade_time: [start_date.at_beginning_of_day..end_date.at_end_of_day]).order(trade_time: :asc)
    records = records.joins(:nft).where(nft: {opensea_slug: slug}) if slug
    data = records.map{|trade| [trade.trade_price, trade.trade_time.strftime("%Y-%m-%d %H:%M")]}.uniq
    {
      data: data
    }
  end

  def get_flip_data
    records = NftFlipRecord.where(sold_time: [start_date.at_beginning_of_day..end_date.at_end_of_day])
    records = records.where(fliper_address: fliper_address) if fliper_address
    records = records.where(slug: slug) if slug
    data = records.order(sold_time: :asc).map{|r| [r.crypto_revenue, r.sold_time.strftime("%Y-%m-%d %H:%M")]}.uniq
    {
      data: data
    }
  end

  def get_flip_count
    result = {}
    records = NftFlipRecord.where(sold_time: [start_date.at_beginning_of_day..end_date.at_end_of_day])
    records = records.where(fliper_address: fliper_address) if fliper_address
    records = records.where(slug: slug) if slug
    records.group_by{|r| r.sold_time.to_date}.sort_by{|date, records| date}.each do |date, records|
      result.merge!({date => {total_count: records.size, successful_count: records.count{|n| n.roi > 0 || n.same_coin? && n.crypto_roi > 0}, failed_count: records.count{|n| n.roi < 0 || n.same_coin? && n.crypto_roi < 0}, date: date}})
    end
    result
  end
end