FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { 100 }
    description { "A test product" }
    user
  end
end
