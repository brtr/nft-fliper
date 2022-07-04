require 'rails_helper'

RSpec.describe Nft, type: :model do
  before(:each) do
    @nft = create(:nft)
    WebMock.enable!
  end

  after do
    WebMock.disable!
  end

  it "have a valid factory" do
    expect(@nft).to be_valid
  end

  it { should have_many(:nft_trades) }

  describe "Sync data from opensea" do
    it "sync opensea stats" do
      stub_request(:get, "https://api.opensea.io/api/v1/collection/#{@nft.opensea_slug}/stats").
        with(
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})

      @nft.sync_opensea_stats
    end

    it "sync opensea info" do
      stub_request(:get, "https://api.opensea.io/api/v1/asset_contract/#{@nft.address}").
        with(
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})

      @nft.sync_opensea_info
    end

    it "sync opensea trades" do
      start_at = Time.now
      end_at = Time.now
      stub_request(:get, "https://api.opensea.io/api/v1/events?collection_slug=#{@nft.opensea_slug}&event_type=successful&occurred_after=#{start_at.to_i}&occurred_before=#{end_at.to_i}").
        with(
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: "", headers: {})

      @nft.sync_opensea_trades(start_at: start_at, end_at: end_at)
    end 
  end

  describe "Add new nft" do
    it "should add new nft" do
      Nft.add_new("azuki", solanart_slug: "azuki")
      expect(Nft.count).to eq(2)
    end
  end
end
