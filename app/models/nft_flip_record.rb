class NftFlipRecord < ApplicationRecord
  include ApplicationHelper

  belongs_to :nft, touch: true

  scope :today, -> { where(sold_time: [Date.yesterday.at_beginning_of_day..Date.today.at_end_of_day]) }

  ETH_PAYMENT = ["ETH", "WETH"]

  def is_eth_payment?
    bought_coin.in?(ETH_PAYMENT) && sold_coin.in?(ETH_PAYMENT)
  end

  def same_coin?
    bought_coin == sold_coin || is_eth_payment?
  end

  def crypto_revenue
    sold - bought
  end

  def crypto_roi
    bought == 0 ? 0 : crypto_revenue / bought
  end

  def display_message
    "
    #{decimal_format bought} #{bought_coin} ($#{decimal_format bought_usd}) / #{decimal_format sold} #{sold_coin} ($#{decimal_format sold_usd}) / #{decimal_format crypto_revenue} #{sold_coin} ($#{decimal_format revenue})

    #{date_format bought_time} - #{date_format sold_time}

    #{I18n.t("views.labels.gap")}: #{ActiveSupport::Duration.build(gap).parts.except(:minutes, :seconds).map { |unit, n| I18n.t unit, count: n, scope: 'duration' }.to_sentence}
    "
  end

  def self.successful
    select{|n| n.roi > 0 || n.same_coin? && n.crypto_roi > 0}
  end

  def self.failed
    select{|n| n.roi < 0 || n.same_coin? && n.crypto_roi < 0}
  end

  class << self
    def get_flipa_winners(bought_start_date: 7.days.ago, sold_start_date: 7.days.ago, gap: 3*24*60*60, number: 10)
      sql = <<-SQL
        WITH fliper_counts AS (
              select fliper_address, count(*) as total_count from nft_flip_records where gap < #{gap} and bought_time > '#{bought_start_date.to_date.to_s}' and sold_time > '#{sold_start_date.to_date.to_s}' group by fliper_address
        ), win_fliper_counts AS (
              select fliper_address, count(*) as win_count from nft_flip_records where gap < #{gap} and roi > 0 and bought_time > '#{bought_start_date.to_date.to_s}' and sold_time > '#{sold_start_date.to_date.to_s}' group by fliper_address
        )
        select win_fliper_counts.fliper_address, win_fliper_counts.win_count/total_count*100 as win_rate, win_fliper_counts.win_count, total_count
        from fliper_counts
        LEFT JOIN win_fliper_counts
        ON win_fliper_counts.fliper_address = fliper_counts.fliper_address
        where win_fliper_counts.win_count > 1 
        order by win_rate desc, win_count desc
        limit #{number};
      SQL
      NftFlipRecord.connection.select_all(sql)
    end

    def get_best_flipas(fliper_address:, gap: 24*60*60, bought_start_date: 3.days.ago, slug: nil, number: 3)
      res = NftFlipRecord.where(fliper_address: fliper_address).where("roi > 0").group(:slug).count
      puts "购买的collection情况： #{res.to_s}"
      results = if slug.present?
        NftFlipRecord.where(fliper_address: fliper_address)
          .where("gap < ?", gap)
          .where(slug: slug)
          .where("bought_time > ?", bought_start_date)
          .order(revenue: :desc, gap: :asc).limit(number)
      else
        NftFlipRecord.where(fliper_address: fliper_address)
          .where("gap < ?", gap)
          .where("bought_time > ?", bought_start_date)
          .order(revenue: :desc, gap: :asc).limit(number)
      end
      results.each do |_res|
        puts "#{_res.bought_time.to_s}以$#{_res.bought_usd.to_i}买入， 在#{_res.sold_time.to_s}以#{_res.sold_usd.to_i}卖出（roi:#{_res.roi}/gap:#{(_res.gap/60.0/60).round(2)}h）   https://opensea.io/assets/#{_res.token_address}/#{_res.token_id}"
      end;puts"------------------------"
    end
  end
end
