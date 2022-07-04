require 'rails_helper'

RSpec.describe UserPoint, type: :model do
  let(:record) { create(:user_point) }

  it "have a valid factory" do
    expect(record).to be_valid
  end
end
