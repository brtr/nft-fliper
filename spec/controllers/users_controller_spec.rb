require "rails_helper"

RSpec.describe UsersController do
  before(:each) do
    @user = create(:user)
    session[:user_id] = @user.id
  end

  describe "POST #login" do
    it "login success" do
      get :login, params: { address: @user.address }
      expect(session[:user_id]).to eq @user.id
    end
  end

  describe "POST #logout" do
    it "logout success" do
      get :logout
      expect(session[:user_id]).to be_nil
    end
  end

  describe "POST #subscribe" do
    it "gets is_subscribed" do
      get :subscribe, params: {month: 1}
      expect(JSON.parse(response.body)["is_subscribed"]).to be_truthy
    end
  end

  describe "POST #stake_token" do
    it "gets true" do
      get :stake_token
      expect(JSON.parse(response.body)["success"]).to be_truthy
    end
  end

  describe "POST #claim_token" do
    it "gets points" do
      @user.user_points.create(staking_time: Time.now - 1.hour)
      get :claim_token, params: {month: 1}
      expect(JSON.parse(response.body)["points"]).to eq(1)
    end
  end
end