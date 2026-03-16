FactoryBot.define do
  factory :diary do
    date { Date.today }
    body { '本文' }
    association :user
    association :emoji
    association :family
  end
end
