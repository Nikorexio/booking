class Hotel < ApplicationRecord
  belongs_to :city

  has_many :rooms
  has_many :reviews
  has_many_attached :images

  scope :with_amenities, ->(amenities) {
    joins(:rooms).where(rooms: amenities).distinct
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_amenities]
  end

  def display_rating
    rating || "Нет оценок"
  end

  def update_rating
    new_rating = reviews.average(:rating)
    update(rating: new_rating)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "city_id", "created_at", "description", "id", "name", "rating", "updated_at"] + super
  end

  def self.ransackable_associations(auth_object = nil)
    ["city", "rooms", "reviews"] + super
  end

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  scope :by_city, ->(city_id) { where(city_id: city_id) if city_id.present? }
end
