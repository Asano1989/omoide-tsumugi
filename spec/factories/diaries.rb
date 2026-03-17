FactoryBot.define do
  factory :diary do
    date { Date.today }
    body { '本文' }
    association :user
    association :emoji
    association :family
    # 1人の子どもを関連付ける
    after(:create) do |diary|
      create(:diary_child, diary: diary, child: create(:child, family: diary.family))
    end

    trait :with_two_children do
      after(:create) do |diary|
        diary.diary_children.destroy_all
        2.times do
          create(:diary_child, diary: diary, child: create(:child, family: diary.family))
        end
      end
    end

    trait :without_children do
      after(:create) do |diary|
        diary.diary_children.destroy_all
      end
    end
  end
end
