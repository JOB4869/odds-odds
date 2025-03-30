FactoryBot.define do
  factory :account do
    user
    balance { 0 }
  end
end
