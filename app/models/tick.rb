class Tick < ActiveRecord::Base
  belongs_to :day, inverse_of: :ticks

  delegate :sym, to: :day
end
