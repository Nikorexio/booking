FactoryBot.define do
  factory :room do
    association :hotel 
    sequence(:number) { |n| "Room #{n}" }
    room_type { ['Стандарт','Люкс','Премиум','Полу-люкс'].sample }
    capacity { rand(1..5) }
    price { rand(500..5000).round(-2) }

    trait :available_between do
      transient do
        check_in { Date.today }
        check_out { Date.tomorrow }
      end
    end
  end
end