class FetchNftFlipRecordsJob < ApplicationJob
  queue_as :daily_job

  def perform
    NftHistoryService.fetch_flip_data
  end
end