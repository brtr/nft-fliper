require 'rails_helper'

RSpec.describe NftTrade, type: :model do
  let(:trade) { create(:nft_trade) }

  it "have a valid factory" do
    expect(trade).to be_valid
  end
end
