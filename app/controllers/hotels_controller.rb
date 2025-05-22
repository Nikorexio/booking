class HotelsController < ApplicationController
  before_action :set_hotel, only: [:show]
  include Pagy::Backend
  # GET /hotels
  def index
    @q = Hotel.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?

    search_relation = @q.result(distinct: true)
                         .includes(:city, :rooms, :reviews)
                         .with_attached_images
    
    @pagy, @hotels = pagy(
      search_relation,
      items: 12
    )
  end

  def log_action
    Rails.logger.info("Action logged: #{params[:action_name]}")
    head :ok
  end

  # GET /hotels/1
  def show
    @review = Review.new # Для формы отзыва
    @reviews = @hotel.reviews.includes(:user).order(created_at: :desc)
    
    @booked_dates = @hotel.rooms.flat_map(&:booked_dates).map { |d| { from: d[:from].to_s, to: d[:to].to_s } }.uniq
    if params[:check_in].present? && params[:check_out].present?
      begin
        @check_in = Date.parse(params[:check_in])
        @check_out = Date.parse(params[:check_out])
        if @check_in >= @check_out
           flash.now[:alert] = "Дата выезда должна быть после даты заезда."
           @rooms = @hotel.rooms # Показываем все комнаты, если даты некорректны
        elsif @check_in < Date.current
           flash.now[:alert] = "Дата заезда не может быть в прошлом."
           @rooms = @hotel.rooms # Показываем все комнаты
        else
           # Используем scope available_between для фильтрации доступных комнат
           @rooms = @hotel.rooms.available_between(@check_in, @check_out)
        end
      rescue Date::Error
        flash.now[:alert] = "Некорректный формат даты"
        @rooms = @hotel.rooms
      end
    else
      @rooms = @hotel.rooms
    end
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:id])
  end
end