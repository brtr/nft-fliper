class User < ApplicationRecord
  has_many :nfts
  has_many :user_points

  def nfts_views
    NftsView.includes(:nft).select{|n| n.user_id == id}
  end
end
