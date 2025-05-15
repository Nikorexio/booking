class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room_and_dates, only: [:new, :create]

  def new
    @reservation = current_user.reservations.new(
      room: @room,
      check_in: @check_in,
      check_out: @check_out,
      guests: params[:guests] || 1
    )
    @total_price = calculate_total_price
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.room = @room
    @reservation.total_price = calculate_total_price

    if @reservation.save
      redirect_to profile_path, notice: "Бронь успешно создана!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation = current_user.reservations.find(params[:id])
    
    if @reservation.cancelable?
      @reservation.update_column(:canceled_at, Time.current)
      redirect_to profile_path, notice: "Бронь успешно отменена"
    else
      redirect_to profile_path, alert: "Невозможно отменить эту бронь"
    end
  end

  private

  def set_room_and_dates
    room_id = params[:room_id] || params.dig(:reservation, :room_id)
  
    # Для POST-запросов (create) параметры внутри reservation:
    check_in = params[:check_in] || params.dig(:reservation, :check_in)
    check_out = params[:check_out] || params.dig(:reservation, :check_out)

    unless room_id.present? && check_in.present? && check_out.present?
      redirect_to hotel_path(Room.find(room_id).hotel), 
                  alert: "Необходимо выбрать даты и номер"
      return
    end

    begin
      @room = Room.find(room_id)
      @check_in = Date.parse(check_in)
      @check_out = Date.parse(check_out)
      
      if @check_out <= @check_in
        redirect_back fallback_location: hotel_path(@room.hotel),
                      alert: "Дата выезда должна быть позже заезда"
      end

    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Комната не найдена"
    rescue Date::Error
      redirect_back fallback_location: hotel_path(@room.hotel),
                    alert: "Некорректный формат даты"
    end
  end

  def calculate_total_price
    nights = (@check_out - @check_in).to_i
    nights * @room.price
  end

  def reservation_params
    params.require(:reservation).permit(:check_in, :check_out, :guests, :room_id)
    # :total_price
  end

end