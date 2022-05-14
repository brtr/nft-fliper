class User < ApplicationRecord
  has_many :nfts

  def nfts_views
    NftsView.includes(:nft).select{|n| n.user_id == id}
  end
end
