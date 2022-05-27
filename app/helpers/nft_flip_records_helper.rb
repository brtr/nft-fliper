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

  def get_data(data, type, count=10)
    if type == "top"
      data.map do |k,v|
        records = v.select{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0}
        next if records.blank?
        record = records.first
        volume = records.count * get_average_price(records)
        [k, records.count, get_revenue(records), get_average_price(records), record.sold_coin, get_average_gap(records),
        record.nft.logo, volume, record.image, get_average_revenue(records)]
      end.compact.sort_by{|r| r[1]}.reverse.first(count)
    else
      data.map do |k,v|
        records = v.select{|n| n.roi_usd < 0 || n.same_coin? && n.roi < 0}
        next if records.blank?
        record = records.first
        volume = records.count * get_average_price(records)
        [k, records.count, get_revenue(records), get_average_price(records), record.sold_coin, get_average_gap(records),
        record.nft.logo, volume, record.image, get_average_revenue(records)]
      end.compact.sort_by{|r| r[1]}.reverse.first(count)
    end
  end

  def get_revenue(records)
    record = records.first
    if record.is_eth_payment?
      "$#{decimal_format records.sum(&:revenue_usd)}"
    else
      "#{decimal_format records.sum(&:revenue)} #{record.sold_coin}"
    end
  end

  def get_average_price(records)
    price_list = records.map{|r| [r.bought, r.sold]}.flatten
    price_list.sum.to_f / price_list.size.to_f
  end

  def get_average_revenue(records)
    record = records.first
    if record.is_eth_payment?
      total_revenue = records.sum(&:revenue_usd)
      "$#{decimal_format total_revenue.to_f / records.size.to_f}"
    else
      total_revenue = records.sum(&:revenue)
      "#{decimal_format total_revenue.to_f / records.size.to_f} #{record.sold_coin}"
    end
  end

  def get_average_gap(records)
    gaps = records.map(&:gap)
    gaps.sum.to_f / gaps.size.to_f
  end
end
