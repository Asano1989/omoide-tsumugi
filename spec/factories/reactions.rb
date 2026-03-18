FactoryBot.define do
  factory :reaction do
    association :user
    association :emoji
    association :diary
  end
end
