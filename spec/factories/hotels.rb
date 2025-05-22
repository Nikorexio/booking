FactoryBot.define do
  factory :hotel do
    name { Faker::Company.name + " Отель" }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    association :city

    trait :with_images do
      after(:create) do |hotel|
        # Requires activestorage fixture helper setup in rails_helper
        hotel.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'hotel_image.jpg')), filename: 'hotel_image.jpg', content_type: 'image/jpeg')
      end
    end

    trait :with_rooms do
      after(:create) do |hotel|
        create_list(:room, 3, hotel: hotel)
      end
    end

    trait :with_reviews do
      after(:create) do |hotel|
        create_list(:review, 4, hotel: hotel)
      end
    end
  end
end