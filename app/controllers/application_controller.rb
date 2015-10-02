class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  include Consul::Controller

  before_action :redirect_to_maintenance, if: :maintenance_enabled
  before_action :require_login

  current_power do
    Power.new(current_user)
  end

  rescue_from Consul::Powerless do |_exception|
    flash[:error] = 'You must be signed in.' unless signed_in?
  end

  private

  def require_login
    raise Consul::Powerless unless current_user
  end

  def redirect_to_maintenance
    redirect_to :root
  end

  def maintenance_enabled
    Maintenance.enabled?
  end
end
