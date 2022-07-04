require "rails_helper"

RSpec.describe FetchSingleNftTradesJob, type: :job do
  subject { described_class.new }

  describe '#FetchSingleNftTradesJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      nft = create(:nft, chain_id: 101)

      expect {
        described_class.perform_later
      }.to have_enqueued_job(FetchSingleNftTradesJob).on_queue('single_job')
    end
  end
end
