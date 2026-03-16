FactoryBot.define do
  factory :child do
    name { '子ども' }
    birthday { Date.today }
  end
end
