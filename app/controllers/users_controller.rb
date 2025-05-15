class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @reservations = current_user.reservations
      .includes(room: :hotel)
      .order(created_at: :desc)
    @reviews = current_user.reviews.includes(:hotel)
  end
end