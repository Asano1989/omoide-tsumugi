FactoryBot.define do
  factory :user do
    sequence(:email) { "test#{_1}@example.com" }
    password { 'password123' }
    password_confirmation { password }
    name { '名前太郎' }
    birthday { '1999-01-01' }
    sequence(:supabase_uid) { "supabase_uid_test#{_1}" }
  end
end
