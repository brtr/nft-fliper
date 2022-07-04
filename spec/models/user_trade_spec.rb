require 'rails_helper'

RSpec.describe UserTrade, type: :model do
  let(:trade) { create(:user_trade) }

  it "have a valid factory" do
    expect(trade).to be_valid
  end
end
