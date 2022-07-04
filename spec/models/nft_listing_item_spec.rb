require 'rails_helper'

RSpec.describe NftListingItem, type: :model do
  let(:item) { create(:nft_listing_item) }

  it "have a valid factory" do
    expect(item).to be_valid
  end
end
