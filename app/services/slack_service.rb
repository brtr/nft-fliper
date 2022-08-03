# Send notification to Slack channel
class SlackService
  class << self
    def send_notification(text, blocks = [])
      url ||= ENV["SLACK_MONITOR_CHANNEL"]
      return if url.blank? || (text.blank? && blocks.blank?)
      return unless Rails.env.production?

      Net::HTTP.post URI(url),
              {text: "*#{Rails.application.class.module_parent_name}*\n #{text}", blocks: blocks}.to_json,
              "Content-Type" => "application/json"
    end
  end
end