FactoryBot.define do
  factory :city do
    name { Faker::Address.city }

    trait :with_hotels do
      after(:create) do |city|
        create_list(:hotel, 2, city: city)
      end
    end
  end
end