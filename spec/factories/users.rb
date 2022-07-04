FactoryBot.define do
  factory :user do
    address { Faker::Blockchain::Ethereum.address }
    points { 0 }
  end
end
