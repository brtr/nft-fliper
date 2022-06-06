class SendNotificationToDiscordJob < ApplicationJob
  queue_as :default

  def perform
    result = []
    id = $redis.get("last_nft_flip_record_id").to_i
    last = NftFlipRecord.maximum(:id)
    if id < last
      $redis.set("last_nft_flip_record_id", last)
      NftFlipRecord.where(id: [id..last]).order(sold_time: :desc).group_by(&:slug).each do |slug, records|
        records = records.select{|r| (r.is_eth_payment? && r.bought < 1) || (r.is_sol_payment? && r.bought < 40)}
        next if records.size < 1
        result.push([slug.upcase, records.size])
        DiscordService.send_notification(slug, records.map(&:display_message).join("\n"))
        sleep 1
      end

      DiscordService.send_notification("FLIP推送次数排行", result.sort_by{|r| r[1]}.reverse.first(10).map{|r| r.join(" - ")}.join("\n"), ENV["FLIP_COUNT_WEBHOOK"]) if result.any?
    end
  end
end