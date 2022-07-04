FactoryBot.define do
  factory :nft do
    chain_id { 1 }
    opensea_slug { Faker::CryptoCoin.coin_hash[:acronym] }
    slug { Faker::CryptoCoin.coin_hash[:acronym] }
    address { Faker::Blockchain::Ethereum.address }
  end
end
