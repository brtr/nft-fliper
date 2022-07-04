require "rails_helper"

RSpec.describe FetchSolanaNftListingsJob, type: :job do
  subject { described_class.new }

  describe '#FetchSolanaNftListingsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      nft = create(:nft, chain_id: 101)

      expect {
        described_class.perform_later
      }.to have_enqueued_job(FetchSolanaNftListingsJob).on_queue('daily_job')
    end
  end
end
