FactoryBot.define do
  factory :diary_child do
    association :diary
    association :child
  end
end
