class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validate :cannot_cancel_after_check_in
  validates :total_price, presence: true
  validates :check_in, :check_out, :guests, presence: true
  validate :check_out_after_check_in
  validate :guests_within_capacity
  validate :dates_availability
  validate :check_in_not_in_past
  # validates :payment_intent_id, uniqueness: true, allow_nil: true

  def cancelable?
    check_in > Date.today or check_out < Date.today
  end

  def canceled?
    canceled_at.present?
  end

  private

  def dates_availability
    return if room.available_between?(check_in, check_out)

    errors.add(:base, "Номер недоступен на выбранные даты")
  end

  def check_in_not_in_past
    return if check_in.blank? || check_in >= Date.current

    errors.add(:check_in, "не может быть в прошлом")
  end

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?
    errors.add(:check_out, "должна быть после даты заезда") if check_out <= check_in
  end

  def guests_within_capacity
    return if guests.blank? || room.blank?
    errors.add(:guests, "превышает вместимость номера") if guests > room.capacity
  end

  def cannot_cancel_after_check_in
    if canceled_at_changed? && check_in <= Date.today
      errors.add(:base, "Невозможно отменить начавшуюся бронь")
    end
  end

  def confirm_payment!
    update!(payment_status: 'paid', payment_intent_id: payment_intent_id)
  end

  def payment_valid?
    payment_status == 'paid' && total_price == (payment_intent.amount_received / 100.0)
  rescue Stripe::InvalidRequestError
    false
  end

  def payment_intent
    Stripe::PaymentIntent.retrieve(payment_intent_id) if payment_intent_id.present?
  end
end
