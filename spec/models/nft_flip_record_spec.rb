require 'rails_helper'

RSpec.describe NftFlipRecord, type: :model do
  before(:each) do
    @nft = create(:nft)
    @record = create(:nft_flip_record, nft: @nft, slug: @nft.opensea_slug, sold: 10, bought: 1, revenue: 9, roi: 9, gap: 40000)
  end

  it "have a valid factory" do
    expect(@record).to be_valid
  end

  describe "Class methods" do
    it "should return get_best_flipas" do
      result = NftFlipRecord.get_best_flipas(fliper_address: @record.fliper_address)

      expect(result.scan(/collection/)).to be_truthy
      expect(result.scan(/opensea/)).to be_truthy
    end


    it "should return get_successful_flips_gap" do
      @data = NftFlipRecord.get_successful_flips_gap(nft: @nft)

      expect(@data.count).to eq (1)
    end

    it "should return get_flips_revenue_rate" do
      @data = NftFlipRecord.get_flips_revenue_rate(nft: @nft)

      expect(@data.count).to eq (1)
    end
  end
end
