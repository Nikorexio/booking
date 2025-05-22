FactoryBot.define do
  factory :review do
    association :hotel
    association :user
    rating { rand(1..5) }
    comment { Faker::Lorem.sentence }
  end
end