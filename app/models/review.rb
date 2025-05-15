class Review < ApplicationRecord
  belongs_to :user
  belongs_to :hotel

  validates :rating, inclusion: { in: 1..5 }
  validates :comment, length: { minimum: 10, maximum: 500 }
end
