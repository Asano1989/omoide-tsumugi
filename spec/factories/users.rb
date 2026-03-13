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
      name { "！＠＃＄％＆（）＝＊＋「」？＞＜" }
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

    trait :no_email do
      email { '' }
    end

    trait :nil_email do
      email { nil }
    end

    trait :one_character_email do
      email { 'a' }
    end

    trait :too_long_email do
      email { 'a' * 200 + '@' + 'b' * 300 }
    end

    trait :contain_blank_email do
      email { "test @example.com" }
    end

    trait :only_full_width_character_email do
      email { 'メールアドレス' }
    end

    trait :contain_full_width_character_email do
      email { "てすと@example.com" }
    end

    trait :except_atmark_from_email do
      email { "testexample.com" }
    end

    trait :only_half_width_symbol_email do
      email { "!@#$%^&*()_+" }
    end

    trait :contain_half_width_symbol_email do
      email { "!#$%test@example^&*()+.com" }
    end

    trait :except_username_from_email do
      email { "@example.com" }
    end

    trait :except_domain_from_email do
      email { "test@" }
    end

    trait :too_short_password do
      password { "passw" }
    end

    trait :blank_character_password do
      password { "" }
    end

    trait :nil_password do
      password { nil }
    end

    trait :contain_blank_password do
      password { "pas sword" }
    end

    trait :only_full_width_character_password do
      password { "パスワードテスト" }
    end

    trait :contain_full_width_character_password do
      password { "パスword" }
    end

    trait :only_half_width_symbol_password do
      password { "!@#$%^&*()_+" }
    end

    trait :six_character_password do
      password { "pass12" }
    end

    trait :contain_half_width_symbol_password do
      password { "pass123!?" }
    end

    trait :no_password_confirmation do
      password_confirmation { "" }
    end

    trait :nil_password_confirmation do
      password_confirmation { nil }
    end

    trait :future_birthday do
      date = Date.today
      birthday { date+1 }
    end

    trait :no_supabase_uid do
      supabase_uid { "" }
    end

    trait :nil_supabase_uid do
      supabase_uid { nil }
    end
  end
end
