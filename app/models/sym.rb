class Sym < ActiveRecord::Base
  WEEK_DAYS = %w(Sun Mon Tue Wed Thur Fri Sat)

  attr_accessor :week_charts, :historical_chart

  belongs_to :market

  has_many :days, -> { order(:date) }, dependent: :destroy
  has_many :ticks, through: :days
  has_many :historical_datums, -> { order(:date) }, dependent: :destroy

  scope :pending_historical, -> { where(historical_data_logged: nil) }
  scope :unsuccessful_historical, -> { where.not(historical_data_logged: true) }
  scope :successful_historical, -> { where(historical_data_logged: true) }

  scope :pending_intraday, -> { where(last_updated_tick_time: nil) }
  scope :error_intraday, -> { where(intraday_log_error: true) }
  scope :successful_intraday, -> { where.not(last_updated_tick_time: nil) }

  scope :unsuccessful_price, -> { where('current_price IS NULL OR current_price = ?', 0) }
  scope :successful_price, -> { where('current_price IS NOT NULL AND current_price != ?', 0) }

  scope :favorited, -> { where(favorite: true) }
  scope :enabled, -> { where(disabled: [nil, false]) }
  scope :greater_than, -> (sym) { where('id > ?', sym.id) }
  scope :ordered, -> { order(:name) }

  def self.week_day(n)
    WEEK_DAYS[n]
  end

  def to_s
    name
  end

  def as_json(options = {})
    { id: id, text: "#{name} - #{full_name}" }
  end

  def padded(string = ' ')
    name.ljust(7, string)
  end

  def last_tick_logged
    last_day_logged = days.with_ticks.last || Day.new
    last_day_logged.ticks.last || Tick.new(time: 'Jan 1 1900'.to_date)
  end

  def calculate_volatility(number_of_days = 10)
    relevant_days = days.reorder({date: :desc}).limit(number_of_days).to_a
    values = min_and_max_tick_amounts(relevant_days)
    return unless values.values.any?(&:present?)
    100 - ((values[:min] * 100) / values[:max]).round(3)
  end

  def historical_data(max_points = 1000)
    data_points = historical_datums.count
    return if data_points == 0
    skip = ([data_points, max_points].max / max_points.to_f).ceil
    data = historical_datums.where("id%#{skip}=0").pluck(:date, :closing_price)
    data.map{ |datum| [(datum[0].strftime('%s').to_i * 1000), datum[1].to_f] }
  end

  def intraday_data(day_number, n_weeks = nil)
    days_for_weeks = days.reorder({date: :desc}).where('EXTRACT(DOW FROM date) = ?', day_number).limit(n_weeks)
    days_for_weeks.map do |day|
      {
        name: day.to_s,
        data: day_shifted_data(day.ticks.pluck(:time, :amount))
      }
    end
  end

  def past_work_days(n_days)
    stacked_consecutive_days(n_days).map do |date, data_points|
      {
        name: date.strftime('%b %d'),
        data: day_shifted_data(data_points)
      }
    end
  end

  def min_and_max_tick_amounts(days)
    ticks = days.map(&:ticks).inject(:merge)
    { min: ticks.minimum(:amount), max: ticks.maximum(:amount) }
  end

  def min_and_max_historical_dates
    { min: historical_datums.minimum(:date), max: historical_datums.maximum(:date) }
  end

  def penny_stocks
    where('current_price < 1')
  end

  def in_price_range(low, high)
    where("current_price > #{low} AND current_price < #{high}")
  end

  def day_shifted_data(data_points)
    data_points.map do |data_point|
      [day_offset_time(data_point), data_point[1].to_f]
    end
  end

  def week_offset_time(data_point, week_number)
    offset = data_point[0] + (current_week_number - week_number).weeks
    (offset - 4.hours).strftime('%s').to_i * 1000
  end

  def day_offset_time(data_point)
    # what if today is not a business day?
    offset = (Date.today - data_point[0].to_date).to_i
    ((data_point[0] + offset.days) - 4.hours).strftime('%s').to_i * 1000
  end

  def stacked_consecutive_days(n_days)
    n_days_ids = days.reorder({date: :desc}).limit(n_days).pluck(:id)
    combined_scope = Tick.where(day_id: n_days_ids)
    return [] unless combined_scope
    combined_scope.order(:time).pluck(:time, :amount).group_by { |datum| datum[0].to_date }
  end

  def current_week_number
    Date.today.strftime('%U').to_i
  end

  def n_weeks_ago(day_number, n_weeks)
    today = Time.current.to_date
    if today.wday == day_number
      delta = today - 1.week
    elsif today.wday > day_number
      beginning_of_this_week = today - today.wday
      delta = beginning_of_this_week + day_number.days
    else
      beginning_of_last_week = today - (today.wday - 1).week
      delta = beginning_of_last_week + day_number.days
    end
    delta - (n_weeks - 1).weeks
  end

end
