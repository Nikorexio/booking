class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.stripe[:webhook_secret]
      )
    rescue JSON::ParserError => e
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      head :bad_request
      return
    end

    case event.type
    when 'payment_intent.succeeded'
      handle_payment_succeeded(event.data.object)
    end

    head :ok
  end

  private

  def handle_payment_succeeded(payment_intent)
    reservation = Reservation.find_by(payment_intent_id: payment_intent.id)
    return unless reservation

    reservation.confirm_payment!
    UserMailer.payment_success(reservation).deliver_later
  end
end