FactoryBot.define do
  factory :nft_flip_record do
    nft
    token_id { "1" }
    bought_coin {"ETH"}
    sold_coin {"ETH"}
    token_address { Faker::Blockchain::Ethereum.address }
    from_address { Faker::Blockchain::Ethereum.address }
    to_address { Faker::Blockchain::Ethereum.address }
    fliper_address { Faker::Blockchain::Ethereum.address }
    bought_time { Time.now - 1.hour }
    sold_time { Time.now }
  end
end
