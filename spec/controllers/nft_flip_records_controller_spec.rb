require "rails_helper"

RSpec.describe NftFlipRecordsController do
  before(:each) do
    @nft = create(:nft)
    @record = create(:nft_flip_record, nft: @nft, slug: @nft.opensea_slug, sold: 10, bought: 1, revenue: 9)
  end

  describe "GET #index" do
    it "gets index success" do
      get :index
      expect(response.status).to eq 200
    end

    it "assigns @records" do
      get :index
      expect(assigns(:records)).to eq [@record]
    end
  end

  describe "GET #fliper_analytics" do
    it "gets analytics success" do
      get :fliper_analytics, params: {fliper_address: @record.fliper_address}
      expect(response.status).to eq 200
    end
  end

  describe "GET #nft_analytics" do
    it "gets analytics success" do
      get :nft_analytics, params: {slug: @record.slug}
      expect(response.status).to eq 200
    end
  end

  describe "GET #live_view" do
    it "gets live view success" do
      get :live_view, params: {slug: @record.slug}
      expect(response.status).to eq 200
    end
  end

  describe "GET #trending" do
    it "gets trending success" do
      get :trending
      expect(response.status).to eq 200
    end
  end

  describe "GET #flip_flow" do
    it "gets flip flow success" do
      get :flip_flow
      expect(response.status).to eq 200
    end
  end

  describe "GET #check_new_records" do
    it "gets record id" do
      get :check_new_records, params: {slug: @record.slug}
      expect(JSON.parse(response.body)["last_id"]).to eq @record.id
    end
  end

  describe "GET #get_new_records" do
    it "should render js" do
      get :get_new_records, params: {slug: @record.slug}, xhr: true
      expect(response.content_type).to eq("text/javascript; charset=utf-8")
    end
  end

  describe "GET #refresh_listings" do
    it "should render js" do
      get :refresh_listings, params: {slug: @record.slug}, xhr: true
      expect(response.content_type).to eq("text/javascript; charset=utf-8")
    end
  end

  describe "GET #search_collection" do
    it "gets records list" do
      get :search_collection
      expect(JSON.parse(response.body)).to eq [{"id" => @nft.id, "text" => @nft.opensea_slug}]
    end
  end
end