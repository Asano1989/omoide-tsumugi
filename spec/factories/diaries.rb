FactoryBot.define do
  factory :diary do
    date { Date.today }
    body { '本文' }
    association :emoji

    # familyを基準にしてuserを作成
    transient do
      family_instance { create(:family) }
    end
    
    family { family_instance }
    user { create(:user, family: family_instance) }
    
    # 1人の子どもを関連付ける
    after(:build) do |diary|
      diary.children << build(:child, family: diary.family)
    end

    trait :nil_date do
      date { nil }
    end

    trait :invalid_date do
      date { '不正な日付' }
    end

    trait :future_date do
      date { Date.today + 1 }
    end

    trait :zero_character_body do
      body { '' }
    end

    trait :nil_body do
      body { nil }
    end

    trait :blank_character_body do
      body { ' ' }
    end

    trait :symbol_only_body do
      body { '!!!???' }
    end

    trait :emoji_only_body do
      body { '😀😃😄' }
    end

    trait :blank_and_symbol_and_emoji_only_body do
      body { '  ！？ 😀 ' }
    end

    trait :with_two_children do
      after(:build) do |diary|
        diary.children.clear
        2.times do
          child = build(:child, family: diary.family)
          diary.children << child
        end
      end
    end

    trait :without_children do
      after(:build) do |diary|
        diary.children.clear
      end
    end

    trait :nil_required_fields do
      date { nil }
      body { nil }
      after(:build) do |diary|
        diary.children.clear
      end
    end
  end
end
