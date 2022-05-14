class NftPurchaseHistory < ApplicationRecord
  belongs_to :nft, touch: true
  belongs_to :owner

  scope :without_target_nfts, -> { includes(:nft).where.not(nft: {is_marked: true})}

  def self.last_day
    date = NftPurchaseHistory.order(purchase_date: :asc).last.purchase_date rescue Date.yesterday
    NftPurchaseHistory.where(purchase_date: date)
  end
end
