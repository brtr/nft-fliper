FactoryBot.define do
  factory :fetch_data_log do
    fetch_type { "auto" }
    source { "Fetch flip data" }
  end
end
