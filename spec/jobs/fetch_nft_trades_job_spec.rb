require "rails_helper"

RSpec.describe FetchNftTradesJob, type: :job do
  subject { described_class.new }

  describe '#FetchNftTradesJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      record = create(:nft_flip_record)

      expect {
        described_class.perform_later
      }.to have_enqueued_job(FetchNftTradesJob).on_queue('daily_job')
    end
  end
end
