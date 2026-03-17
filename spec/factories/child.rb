FactoryBot.define do
  factory :child do
    sequence(:name) { |n| "子ども#{n}" }
    birthday { Date.today }
    association :family
  end
end
