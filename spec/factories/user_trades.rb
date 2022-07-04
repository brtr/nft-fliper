FactoryBot.define do
  factory :user_trade do
    user_address
    collection { "azuki" }
    token_address { "2" }
    from_address { Faker::Blockchain::Ethereum.address }
    to_address { Faker::Blockchain::Ethereum.address }
  end
end
