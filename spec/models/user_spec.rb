require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:user_point) { create(user: user) }

  it "have a valid factory" do
    expect(user).to be_valid
  end

  it { should have_many(:user_points) }
end
