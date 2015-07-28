class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  include Consul::Controller

  current_power do
    Power.new(current_user)
  end

  rescue_from Consul::Powerless do |_exception|
    flash[:error] = 'You do not have access to that area.' unless signed_in?
  end
end
