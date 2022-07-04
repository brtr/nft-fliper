class User < ApplicationRecord
  has_many :nfts
  has_many :user_points
end
