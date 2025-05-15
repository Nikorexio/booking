class City < ApplicationRecord
  has_many :hotels, dependent: :destroy
  validates :name, presence: true, 
                   uniqueness: true,
                   length: { maximum: 50 }
end
