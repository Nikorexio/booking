class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @reservation = current_user.reservations.find(params[:reservation_id])
  end

  def create
    @reservation = current_user.reservations.find(params[:reservation_id])
    
    begin
      payment_intent = Stripe::PaymentIntent.create({
        amount: (@reservation.total_price * 100).to_i,
        currency: 'rub',
        customer: current_user.stripe_customer_id,
        payment_method: params[:payment_method_id],
        off_session: true,
        confirm: true,
        metadata: {
          reservation_id: @reservation.id,
          user_id: current_user.id
        }
      })

      @reservation.update!(
        payment_intent_id: payment_intent.id,
        payment_status: payment_intent.status
      )

      redirect_to reservation_payment_path(@reservation), 
                  notice: "Платеж успешно завершен"
    rescue Stripe::CardError => e
      redirect_to reservation_payment_path(@reservation), 
                alert: "Ошибка платежа: #{e.error.message}"
    end
  end
end