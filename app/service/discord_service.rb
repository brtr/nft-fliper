# Send notification to Slack channel
class DiscordService
  class << self
    def send_notification(title="", text="", url=nil)
      url ||= ENV["DISCORD_WEBHOOK"]
      return if url.blank? || (title.blank? && text.blank?)
      return unless Rails.env.production?

      data = {
        embeds: [
          {
            title: title.upcase,
            description: text
          }
        ]
      }
      Net::HTTP.post URI(url + "?wait=true"),
              data.to_json,
              "Content-Type" => "application/json"
    end
  end
end