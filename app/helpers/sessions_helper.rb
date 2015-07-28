module SessionsHelper
  attr_writer :current_user

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end
end
