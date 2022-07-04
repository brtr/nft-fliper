require 'rails_helper'

RSpec.describe UserAddress, type: :model do
  let(:record) { create(:user_address) }

  it "have a valid factory" do
    expect(record).to be_valid
  end
end
