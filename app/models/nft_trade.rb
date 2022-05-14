class NftTrade < ApplicationRecord
  belongs_to :nft, touch: true

  scope :without_target_nfts, -> { includes(:nft).where.not(nft: {is_marked: true})}

  def self.bch_purchase(date=Date.yesterday)
    target_owners = NftOwnerService.get_target_owners(date)
    owners_address = target_owners.keys
    NftTrade.where(buyer: owners_address, trade_time: [date.at_beginning_of_day..date.at_end_of_day])
  end
end
