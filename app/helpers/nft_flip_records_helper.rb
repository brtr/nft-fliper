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

  def get_data(data, type)
    if type == "top"
      data.map do |k,v|
        records = v.select{|n| n.roi > 0 || n.same_coin? && n.crypto_roi > 0}
        next if records.blank?
        [k, records.count, get_revenue(records), get_average_price(records), records.first.sold_coin, get_average_gap(records)]
      end.compact.sort_by{|r| r[1]}.reverse.first(10)
    else
      data.map do |k,v|
        records = v.select{|n| n.roi < 0 || n.same_coin? && n.crypto_roi < 0}
        next if records.blank?
        [k, records.count, get_revenue(records), get_average_price(records), records.first.sold_coin, get_average_gap(records)]
      end.compact.sort_by{|r| r[1]}.reverse.first(10)
    end
  end

  def get_revenue(records)
    record = records.first
    if record.is_eth_payment?
      "$#{decimal_format records.sum(&:revenue)}"
    else
      "#{decimal_format records.sum(&:crypto_revenue)} #{record.sold_coin}"
    end
  end

  def get_average_price(records)
    price_list = records.map{|r| [r.bought, r.sold]}.flatten
    price_list.sum.to_f / price_list.size.to_f
  end

  def get_average_gap(records)
    gaps = records.map(&:gap)
    gaps.sum.to_f / gaps.size.to_f
  end
end
