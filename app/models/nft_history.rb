class NftHistory < ApplicationRecord
  belongs_to :nft, touch: true
  
end