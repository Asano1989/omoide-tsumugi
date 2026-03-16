FactoryBot.define do
  factory :child do
    name { '子ども' }
    birthday { Date.today }
    association :family
  end
end
