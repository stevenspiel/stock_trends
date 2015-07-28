class Power
  include Consul::Power

  def initialize(user)
    @user = user || User.new
  end

  power :admin do
    @user.try(:admin?)
  end
end
