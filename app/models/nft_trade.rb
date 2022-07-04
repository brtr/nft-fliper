class NftTrade < ApplicationRecord
  belongs_to :nft, touch: true
end
