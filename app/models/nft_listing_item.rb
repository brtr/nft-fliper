class NftListingItem < ApplicationRecord
  belongs_to :nft, touch: true

  enum status: [:listed, :sold, :canceled, :transfered]
end
