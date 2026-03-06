FactoryBot.define do
  factory :user do
    sequence(:email) { "test#{_1}@example.com" }
    password { 'password123' }
    password_confirmation { password }
    name { '名前太郎' }
    birthday { '1999-01-01' }
    sequence(:supabase_uid) { "supabase_uid_test#{_1}" }

    trait :no_name do
      name { '' }
    end

    trait :nil_name do
      name { nil }
    end

    trait :one_character_name do
      name { 'a' }
    end

    trait :blank_character_name do
      name { ' ' }
    end

    trait :contain_blank_name do
      name { '名前 太郎' }
    end

    trait :contain_full_width_blank_name do
      name { '空白　次郎' }
    end

    trait :only_half_width_character_name do
      name { 'abcdef' }
    end

    trait :only_half_width_symbol_name do
      name { "!@#$%^&*()_+" }
    end

    trait :only_full_width_symbol_name do
      name { "！＠＃＄％＆（）＝＊＋ー「」？＞＜" }
    end

    trait :mixed_half_width_and_full_width_character_name do
      name { '名前nameさぶろう1' }
    end

    trait :contain_half_width_symbol_name do
      name { '名前と記号!@#$%^&*()_+' }
    end

    trait :too_long_name do
      name { 'あ' * 51 }
    end
  end
end
