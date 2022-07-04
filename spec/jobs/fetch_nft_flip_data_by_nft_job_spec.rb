require "rails_helper"

RSpec.describe FetchNftFlipDataByNftJob, type: :job do
  subject { described_class.new }

  describe '#FetchNftFlipDataByNftJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      record = create(:nft_flip_record)

      expect {
        described_class.perform_later(record.slug)
      }.to have_enqueued_job(FetchNftFlipDataByNftJob).on_queue('single_job')
    end
  end
end
