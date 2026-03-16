FactoryBot.define do
  factory :emoji do
    sequence(:character) { |n| ['😆', '🥳', '😀', '😊', '😭', '🎉', '❤️'][n % 7] + n.to_s }
  end
end
