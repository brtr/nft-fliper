require 'rails_helper'

RSpec.describe FetchDataLog, type: :model do
  let(:record) { create(:fetch_data_log) }

  it "have a valid factory" do
    expect(record).to be_valid
  end
end
