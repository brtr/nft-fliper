class NftTransfer < ApplicationRecord
  belongs_to :nft, touch: true
end
