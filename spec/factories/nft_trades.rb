FactoryBot.define do
  factory :nft_trade do
    nft
    token_id { "2" }
    buyer { Faker::Blockchain::Ethereum.address }
    seller { Faker::Blockchain::Ethereum.address }
  end
end
