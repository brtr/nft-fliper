class Owner < ApplicationRecord
  has_many :owner_nfts
  has_many :nfts, through: :owner_nfts
  has_many :nft_purchase_histories
end
