require "rails_helper"

RSpec.describe SendNotificationToDiscordJob, type: :job do
  subject { described_class.new }

  describe '#SendNotificationToDiscordJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      record = create(:nft_flip_record)

      expect {
        described_class.perform_later
      }.to have_enqueued_job(SendNotificationToDiscordJob).on_queue('default')
    end
  end
end
