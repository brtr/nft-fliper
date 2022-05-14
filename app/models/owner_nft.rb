class OwnerNft < ApplicationRecord
  acts_as_paranoid

  belongs_to :owner
  belongs_to :nft

  serialize :token_ids
end
