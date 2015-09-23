class LandingPageController < ApplicationController
  before_action :redirect_if_signed_in, only: :show
  skip_before_action :require_login
  layout 'public'

  def show
  end

  private

  def redirect_if_signed_in
    if current_user.present?
      redirect_to syms_path
    end
  end
end
