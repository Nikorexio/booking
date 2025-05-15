class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hotel

  def create
    @review = @hotel.reviews.new(review_params)
    @review.user = current_user

    if @review.save
      @hotel.update_rating
      redirect_to hotel_path(@hotel), notice: "Отзыв успешно опубликован"
    else
      Rails.logger.error "Ошибка сохранения отзыва: #{@review.errors.full_messages}"
    redirect_to hotel_path(@hotel), 
      alert: "Ошибка: #{@review.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    @hotel.update_rating
    redirect_to @hotel, notice: "Отзыв удалён"
  end

  private

  def set_hotel
    @hotel = Hotel.find(params[:hotel_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end