class Room < ApplicationRecord
  belongs_to :hotel
  has_many :reservations, dependent: :destroy
  has_many_attached :photos

  validates :number, :room_type, :price, :capacity, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :available_between, ->(start_date, end_date) {
    left_joins(:reservations)
      .where.not("reservations.check_in < ? AND reservations.check_out > ?", end_date, start_date)
      .or(where(reservations: { id: nil }))
      .distinct
  }

  def self.ransackable_attributes(auth_object = nil)
    ["capacity", "created_at", "hotel_id", "id", "number", "price", "room_type", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["hotel", "reservations"]
  end

  def available_between?(start_date, end_date)
    Room.available_between(start_date, end_date).where(id: id).exists?
  end

  def booked_dates
    reservations.pluck(:check_in, :check_out).map do |range|
      { from: range[0], to: range[1] }
    end
  end
  
end
