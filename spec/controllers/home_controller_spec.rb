require "rails_helper"

RSpec.describe HomeController do
  describe "GET #fliper_pass_nft" do
    it "gets fliper_pass_nft success" do
      get :fliper_pass_nft
      expect(response.status).to eq 200
    end
  end

  describe "GET #staking" do
    it "gets staking success" do
      get :staking
      expect(response.status).to eq 200
    end
  end

  describe "GET #mint" do
    it "gets mint success" do
      get :mint
      expect(response.status).to eq 200
    end
  end

  describe "GET #qanda" do
    it "gets qanda success" do
      get :qanda
      expect(response.status).to eq 200
    end
  end

  describe "GET #not_permitted" do
    it "gets error message" do
      get :not_permitted, params: {error_code: 1}
      expect(JSON.parse(response.body)["message"]).to eq "You don't have any NFTs or subscriptions."
    end
  end
end