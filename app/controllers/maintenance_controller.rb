class MaintenanceController < ApplicationController
  skip_before_action :redirect_to_maintenance
  skip_before_action :require_login

  def show
  end
end
