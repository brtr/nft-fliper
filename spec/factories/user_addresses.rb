FactoryBot.define do
  factory :user_address do
    address { Faker::Blockchain::Ethereum.address }
  end
end
