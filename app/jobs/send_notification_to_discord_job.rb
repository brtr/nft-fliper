class SendNotificationToDiscordJob < ApplicationJob
  queue_as :default

  def perform(ids)
    NftFlipRecord.where(id: ids).each do |n|
      next unless n.is_eth_payment? && n.bought < 1
      DiscordService.send_notification(n.slug, n.display_message)
      sleep 1
    end
  end
end