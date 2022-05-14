class TargetNftOwnerHistory < ApplicationRecord
  belongs_to :nft, touch: true

  serialize :data

  enum n_type: [:holding, :purchase]

  def self.last_day
    date = TargetNftOwnerHistory.order(event_date: :asc).last.event_date rescue Date.yesterday
    TargetNftOwnerHistory.where(event_date: date)
  end

  def self.last_purchase
    TargetNftOwnerHistory.order(event_date: :asc).purchase.last
  end
end
