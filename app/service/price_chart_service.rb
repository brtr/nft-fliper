class PriceChartService
  attr_reader :start_at, :end_at, :nft_id, :fliper_address, :slug

  def initialize(start_at: nil, end_at: nil, nft_id: nil, fliper_address: nil, slug: nil)
    @start_at = start_at
    @end_at = end_at || Time.now
    @nft_id = nft_id
    @fliper_address = fliper_address
    @slug = slug
  end

  def get_trade_data
    records = NftTrade.where(trade_time: [start_at..end_at]).order(trade_time: :asc)
    records = records.joins(:nft).where(nft: {opensea_slug: slug}) if slug
    data = records.map{|trade| [trade.trade_price, trade.trade_time.strftime("%Y-%m-%d %H:%M")]}
    {
      data: data
    }
  end

  def get_flip_data
    records = NftFlipRecord.where(sold_time: [start_at..end_at])
    records = records.where(fliper_address: fliper_address) if fliper_address
    records = records.where(slug: slug) if slug
    data = records.order(sold_time: :asc).map{|r| [r.revenue, r.sold_time.strftime("%Y-%m-%d %H:%M")]}.uniq
    {
      data: data
    }
  end

  def get_flip_count
    result = {}
    records = NftFlipRecord.where(sold_time: [start_at..end_at])
    records = records.where(fliper_address: fliper_address) if fliper_address
    records = records.where(slug: slug) if slug
    records.group_by{|r| r.sold_time.to_date}.sort_by{|date, records| date}.each do |date, records|
      result.merge!({date => {total_count: records.size, successful_count: records.count{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0}, failed_count: records.count{|n| n.roi_usd < 0 || n.same_coin? && n.roi < 0}, date: date}})
    end
    result
  end
end