module NftsHelper
  def logo_path(slug, logo)
    if logo
      logo
    elsif slug
      "https://s3.amazonaws.com/cdn.nftpricefloor/projects/v1/#{slug}.png"
    else
      "default.png"
    end
  end

  def listed_and_supply_radio(nft)
    if nft.listed.present? && nft.listed > 0
      ratio =  nft.listed.to_f / nft.total_supply * 100
      "#{nft.listed.to_i}/#{nft.total_supply} (#{ratio.to_f.round(2)}%) "
    else
      listed = nft.total_supply * nft.listed_ratio / 100 rescue 0
      "#{listed.to_i} / #{nft.total_supply.to_i} (#{nft.listed_ratio.to_f.round(2)}%)"
    end
  end

  def get_chain_name(chain_id)
    case chain_id
    when 1
      "Ethereum"
    when 56
      "Bsc"
    when 137
      "Polygon"
    when 250
      "Fantom"
    when 43114
      "Avalanche"
    else
      ""
    end
  end

  def change_text_color(num)
    if num > 0
      "success"
    elsif num < 0
      "danger"
    else
      "dark"
    end
  end

  def get_count_ratio(nft)
    count = nft.tokens_count
    ratio = (count.to_f / nft.total_supply) rescue 0
    "#{count} (#{(ratio * 100).round(2)}%)"
  end

  def get_purchase_data(nft)
    purchase = nft.target_nft_owner_histories.last_purchase
    data = purchase.data
    tokens_count = data[:tokens_count]
    ratio = (tokens_count.to_f / data[:total_count].to_f) rescue 0
    {
      token_ratio: "#{tokens_count} (#{(ratio * 100).round(2)}%)",
      owners_count: data[:bch_count]
    }
  end

  def fetch_purchase_history_data(data)
    result = {total_count: 0, data: []}
    result[:total_count] = data.sum{|d| d[:total_count]}
    result[:bch_count] = data.sum{|d| d[:bch_count]}

    result
  end

  def get_sales_info(data)
    total_count = data[:total_count].to_f
    bchp = total_count == 0 ? 0 : data[:bch_count] / total_count
    "#{total_count.to_i} (#{(bchp * 100).to_f.round(2)}%)"
  end
end
