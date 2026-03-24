FactoryBot.define do
  factory :family do
    name { 'ファミリー' }
    association :owner, factory: :user

    trait :no_name do
      name { '' }
    end

    trait :nil_name do
      name { nil }
    end

    trait :blank_name do
      name { ' ' }
    end

    trait :one_character_name do
      name { 'a' }
    end

    trait :fifty_characters_name do
      name { 'a' * 50 }
    end

    trait :fifty_one_characters_name do
      name { 'a' * 51 }
    end
  end
end
