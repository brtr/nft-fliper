class UserAddress < ApplicationRecord
  has_many :user_trades, dependent: :destroy
end
