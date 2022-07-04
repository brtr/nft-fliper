FactoryBot.define do
  factory :nft_transfer do
    nft
    token_id { "2" }
    from_address { Faker::Blockchain::Ethereum.address }
    to_address { Faker::Blockchain::Ethereum.address }
  end
end
