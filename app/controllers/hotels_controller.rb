class HotelsController < ApplicationController
  before_action :set_hotel, only: [:show]
  include Pagy::Backend
  # GET /hotels
  def index
    @q = Hotel.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?

    @pagy, @hotels = pagy(
      @q.result(distinct: true)
        .includes(:city, :rooms)
        .with_attached_images,
      items: 12
    )

    if params[:q]&.dig(:rooms_room_type_eq).present?
      room_type = params[:q][:rooms_room_type_eq]
      @hotels = @hotels.joins(:rooms)
                       .where(rooms: { room_type: room_type })
                       .distinct
    end

    if params[:q]&.dig(:rooms_room_price_gteq).present? || 
      params[:q]&.dig(:rooms_room_price_lteq).present? ||
      params[:q]&.dig(:rooms_room_capacity_gteq).present?
 
      @hotels = @hotels.joins(:rooms)
      
      if params[:q][:rooms_room_price_gteq].present?
        @hotels = @hotels.where("rooms.price >= ?", params[:q][:rooms_price_gteq])
      end
      
      if params[:q][:rooms_room_price_lteq].present?
        @hotels = @hotels.where("rooms.price <= ?", params[:q][:rooms_price_lteq])
      end
  
      if params[:q][:rooms_room_capacity_gteq].present?
        @hotels = @hotels.where("rooms.capacity >= ?", params[:q][:rooms_capacity_gteq])
      end
  
      @hotels = @hotels.distinct
    end
  end

  def log_action
    Rails.logger.info("Action logged: #{params[:action_name]}")
    head :ok
  end

  def search
    @q = Hotel.ransack(params[:q])
    @pagy, @hotels = pagy(@q.result.includes(:city), items: 12)
    
    render :index
  end

  # GET /hotels/1
  def show
    @review = Review.new # Для формы отзыва
    @reviews = @hotel.reviews.includes(:user).order(created_at: :desc)
    
    if params[:check_in].present? && params[:check_out].present?
      begin
        @check_in = Date.parse(params[:check_in])
        @check_out = Date.parse(params[:check_out])
        @rooms = @hotel.rooms.available_between(@check_in, @check_out)
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