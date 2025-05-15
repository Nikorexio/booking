class Users::SessionsController < Devise::SessionsController
  def destroy
    super do
      redirect_to root_path, status: :see_other and return
    end
  end
end