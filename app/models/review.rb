class Review < ApplicationRecord
  belongs_to :user
  belongs_to :hotel

  validates :rating, inclusion: { in: 1..5 }
  validates :comment, length: { 
    minimum: 10, 
    maximum: 500,
    too_short: "должен содержать не менее %{count} символов",
    too_long: "должен содержать не более %{count} символов"
  }
end
