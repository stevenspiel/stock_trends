class Api < ActiveRecord::Base
  has_many :syms

  def self.yahoo; find_by(name: 'Yahoo'); end
  def self.quandl; find_by(name: 'Quandl'); end
  def self.market_on_demand; find_by(name: 'Market On Demand'); end
  def self.nasdaq; find_by(name: 'Nasdaq'); end
  def self.trade_king; find_by(name: 'Trade King'); end

  def to_s
    name
  end

  def model_class
    case name
      when 'Yahoo'
        :Yf
      when 'Quandl'
        :Q
      when 'Market On Demand'
        :Mod
      when 'Nasdaq'
        :N
      when 'Trade King'
        :Tk
    end
  end
end
