require 'rails_helper'

RSpec.describe NftTransfer, type: :model do
  let(:transfer) { create(:nft_transfer) }

  it "have a valid factory" do
    expect(transfer).to be_valid
  end
end
