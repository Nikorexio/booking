FactoryBot.define do
  factory :reservation do
    association :user
    association :room

    sequence(:check_in) { |n| Date.today + 1.month + n.days }
    sequence(:check_out) { |n| Date.today + 1.month + n.days + 3.days } #Бронирование на 3 дня

    guests { room.present? && room.capacity.to_i > 0 ? rand(1..room.capacity) : 1 }

    total_price { room.present? ? room.price * (check_out - check_in).to_i : rand(1000..10000) }

    canceled_at { nil }

    trait :canceled do
      canceled_at { Time.current }
      #payment_status = 'refunded' или 'canceled'
    end

    trait :on_dates do
        transient do
            booking_check_in { Date.today }
            booking_check_out { Date.tomorrow }
        end
        after(:build) do |reservation, evaluator|
            reservation.check_in = evaluator.booking_check_in
            reservation.check_out = evaluator.booking_check_out
            if reservation.room.present?
                reservation.total_price = reservation.room.price * (reservation.check_out - reservation.check_in).to_i
            end
        end
    end
  end
end