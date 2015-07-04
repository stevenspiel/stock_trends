class Day < ActiveRecord::Base
  TIMEZONE_OFFSET = 4 # keep it EST for now

  belongs_to :sym

  delegate :market, to: :sym

  has_many :ticks, -> { order(:time) }, dependent: :destroy, inverse_of: :day

  scope :with_ticks, -> { joins(:ticks) }
  scope :without_ticks, -> { includes(:ticks).where(:ticks => { :id => nil }) }

  validates :sym, presence: true
  validates :date, presence: true

  def to_s
    date.strftime('%b %d')
  end

  def add_endpoints(amount = nil)
    return if ticks.none? && amount.nil?
    first_tick_amount = amount || ticks.min_by(&:time).amount
    last_tick_amount = amount || ticks.max_by(&:time).amount
    ticks.build(time: opening_time, amount: first_tick_amount)
    ticks.build(time: closing_time, amount: last_tick_amount)
  end

  def closing_price
    ticks.order(:time).last.try(:price)
  end

  def opening_time
    date + (market.hour_opens + TIMEZONE_OFFSET).hours
  end

  def closing_time
    date + (market.hour_closes + TIMEZONE_OFFSET).hours
  end
end
