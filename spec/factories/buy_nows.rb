FactoryBot.define do
  factory :buy_now do
    user
    product
    amount { 1 }
  end
end
