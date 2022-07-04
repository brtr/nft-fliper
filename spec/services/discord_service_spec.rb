require "rails_helper"

RSpec.describe DiscordService, type: :service do
  describe "#send_notification" do
    it "return nil when env is not production" do
      result = described_class.send_notification
      expect(result).to be nil
    end
  end
end