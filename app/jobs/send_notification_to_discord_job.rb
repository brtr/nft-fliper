class SendNotificationToDiscordJob < ApplicationJob
  queue_as :default

  def perform(ids)
    slugs = ENV["DISCORD_NOTIFICATION_NFT"].split(",")
    NftFlipRecord.where(id: ids, slug: slugs).each do |n|
      DiscordService.send_notification(n.slug, n.display_message)
      sleep 1
    end
  end
end