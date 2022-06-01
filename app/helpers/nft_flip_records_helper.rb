module NftFlipRecordsHelper
  def chain_logo_path(nft_id)
    nft = Nft.find_by id: nft_id
    if nft
      nft.chain_id == 1 ? 'eth.png' : 'solana.png'
    else
      ''
    end
  end

  def platform_logo_path(link)
    if link.match(/opensea/)
      "opensea_blue.svg"
    else
      "solanart.svg"
    end
  end

  def get_data(data, count: 10, period: "day")
    count = period == "week" ? (count == 20 ? 20 : 10) : count
    data.map do |k,v|
      records = v.select{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0}
      next if records.blank? || (period == "day" && records.size < 4) || (period == "week" && records.size < 10)

      rate = (records.size / v.size.to_f) * 100
      volume = records.size * get_average_price(records)
      record = records.first
      [k, records.size, get_revenue(records), get_average_price(records), record.sold_coin, get_average_gap(records),
      record.nft.logo, volume, record.image, get_average_revenue(records), rate, get_total_roi(records)]
    end.compact.sort_by{|r| r[10]}.reverse!.first(count)
  end

  def get_revenue(records)
    record = records.first
    "#{decimal_format records.sum(&:revenue)} #{record.sold_coin}"
  end

  def get_average_price(records)
    records.sum(&:bought) / records.size.to_f
  end

  def get_average_revenue(records)
    record = records.first
    total_revenue = records.sum(&:revenue)
    "#{decimal_format total_revenue.to_f / records.size.to_f} #{record.sold_coin}"
  end

  def get_average_gap(records)
    gaps = records.map(&:gap)
    gaps.sum.to_f / gaps.size.to_f
  end

  def get_rank_gap(idx)
    if idx == 0
      I18n.t("datetime.prompts.hour")
    elsif idx == 1
      I18n.t("datetime.prompts.day")
    else
      I18n.t("datetime.prompts.week")
    end
  end

  def get_successful_rate(records)
    successful_count = records.count{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0}
    (successful_count / records.size) * 100
  end

  def get_total_roi(records)
    total_revenue = records.sum(&:revenue)
    total_price = records.sum(&:bought)
    total_revenue / total_price
  end
end
