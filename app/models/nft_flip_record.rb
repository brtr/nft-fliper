class NftFlipRecord < ApplicationRecord
  include ApplicationHelper

  belongs_to :nft, touch: true

  scope :hour, -> { where(sold_time: [Time.now - 1.hour..Time.now]) }
  scope :today, -> { where(sold_time: [Time.now - 1.day..Time.now]) }
  scope :week, -> { where(sold_time: [Time.now - 7.days..Time.now]) }

  ETH_PAYMENT = ["ETH", "WETH"]

  def is_eth_payment?
    bought_coin.in?(ETH_PAYMENT) && sold_coin.in?(ETH_PAYMENT)
  end

  def is_sol_payment?
    bought_coin == "SOL" && sold_coin == "SOL"
  end

  def same_coin?
    bought_coin == sold_coin || is_eth_payment?
  end

  def display_message
    usd_value = is_sol_payment? ? "" : "($#{decimal_format revenue_usd})"
    "
    #{decimal_format bought} #{bought_coin} / #{decimal_format sold} #{sold_coin} / #{decimal_format revenue} #{sold_coin} #{usd_value}

    #{date_format bought_time} - #{date_format sold_time} #{I18n.t("views.labels.gap")}: #{humanize_gap(gap)}

    [More](#{permalink})
    "
  end

  def self.successful
    select{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0}
  end

  def self.failed
    select{|n| n.roi_usd < 0 || n.same_coin? && n.roi < 0}
  end

  def self.successful_rate
    successful.size.to_f / all.size.to_f
  end

  def display_name
    token_id[6..-10] = "..." if token_id.size > 10
    "#{slug}##{token_id}"
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

    def get_successful_flips_gap(nft: nil, from_date: nil, to_date: nil)
      records = get_data(nft: nft, from_date: from_date, to_date: to_date)
      records.successful.map do |r|
        gap_hour = r.gap / 3600
        gap_day = gap_hour / 24
        [r.id, r.slug, gap_day.to_i, gap_hour.to_i]
      end
    end

    def get_flips_revenue_rate(nft: nil, from_date: nil, to_date: nil)
      records = get_data(nft: nft, from_date: from_date, to_date: to_date)
      records.group_by(&:roi).map do |revenue_rate, data|
        [revenue_rate.round(2), data.select{|d| d.revenue > 0}.count, data.select{|d| d.revenue < 0}.count]
      end
    end

    def get_data(nft: nil, from_date: nil, to_date: nil)
      records = NftFlipRecord.where("bought_coin in (?) and sold_coin in (?)", ETH_PAYMENT, ETH_PAYMENT)
      records = records.where(nft: nft) if nft.present?
      records = records.where("sold_time >= ?", from_date) if from_date.present?
      records = records.where("sold_time <= ?", to_date) if to_date.present?
      records
    end

    def get_rank_data(slug: nil, fliper_address: nil)
      weekly_records = NftFlipRecord.includes(:nft).where("gap < ? or revenue > ?", 86400, 2).week
      daily_records = weekly_records.today
      hourly_records = daily_records.hour

      [[0, hourly_records], [1, daily_records], [2, weekly_records]].map do |idx, records|
        if slug
          k_word = slug
          rank_data = records.group_by(&:slug)
          target_records = records.where(slug: slug)
        end

        if fliper_address
          k_word = fliper_address
          rank_data = records.group_by(&:fliper_address)
          target_records = records.where(fliper_address: fliper_address)
        end

        rank =  rank_data.sort_by{|k, v| (v.count{|n| n.roi_usd > 0 || n.same_coin? && n.roi > 0} / v.size.to_f) * 100}.reverse.map do |k,v|
                  next if (idx == 1 && v.size < 4) || (idx == 2 && v.size < 10);
                  k
                end.compact.index(k_word) + 1 rescue 0

        successful = target_records.successful rescue []
        failed = target_records.failed rescue []
        coin = target_records.first.sold_coin rescue ""
        [rank, target_records.size, successful.count, failed.count, target_records.sum(&:revenue), successful.sum(&:revenue), failed.sum(&:revenue), coin]
      end
    end
  end
end
