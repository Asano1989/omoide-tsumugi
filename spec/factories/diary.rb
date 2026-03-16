FactoryBot.define do
  factory :diary do
    date { Date.today }
    body { '本文' }
  end
end
