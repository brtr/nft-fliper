require "rails_helper"

RSpec.describe UserFlipService, type: :service do
  let(:user) { create(:user_address) }

  describe "#add_address" do
    it "should add user address" do
      described_class.add_address(user.address)
      expect(UserAddress.count).to eq(1)
    end
  end

  describe "#get_flip_records" do
    it "should fetch flip data" do
      record = create(:user_trade, user_address: user)
      described_class.get_flip_records(user.address)
      expect(UserTrade.count).to eq(1)
    end
  end
end