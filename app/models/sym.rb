class Sym < ActiveRecord::Base
  WEEK_DAYS = %w(Sun Mon Tue Wed Thur Fri Sat)

  attr_accessor :week_charts, :historical_chart

  belongs_to :market
  belongs_to :historical_api, class_name: Api
  belongs_to :intraday_api, class_name: Api

  has_many :ticks, -> { order(:time) }, dependent: :destroy
  has_many :historical_datums, -> { order(:date) }, dependent: :destroy

  scope :pending_historical, -> { where(historical_data_logged: nil) }
  scope :unsuccessful_historical, -> { where('historical_data_logged != ?', true) }
  scope :successful_historical, -> { where(historical_data_logged: true) }

  scope :pending_intraday, -> { where(last_updated_tick_time: nil) }
  scope :error_intraday, -> { where(intraday_log_error: true) }
  scope :successful_intraday, -> { where('last_updated_tick_time IS NOT NULL') }

  scope :unsuccessful_price, -> { where('current_price IS NULL OR current_price = ?', 0) }
  scope :successful_price, -> { where('current_price IS NOT NULL AND current_price != ?', 0) }

  scope :favorited, -> { where(favorite: true) }
  scope :enabled, -> { where('disabled IS NULL OR disabled = ?', false) }
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

  def calculate_volatility(days = 10)
    min_date = days.business_days.before(Date.today)
    values = min_and_max_tick_amounts(min_date)
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
    grouped_by_day(day_number, n_weeks).map do |week_number, data_points|
      {
        name: day(week_number, day_number),
        data: week_shifted_data(week_number, data_points)
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

  def min_and_max_tick_amounts(min_date = nil, max_date = nil)
    scoped_ticks = min_date || max_date ?
      self.ticks.where('time BETWEEN ? AND ?', (min_date || 'Jan 1 1900'.to_date), (max_date || Date.today)) :
      self.ticks.all
    { min: scoped_ticks.minimum(:amount), max: scoped_ticks.maximum(:amount) }
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

  def week_shifted_data(week_number, data_points)
    # TODO: turn these into days and use #day_shifted_data
    data_points.map do |data_point|
      [week_offset_time(data_point, week_number), data_point[1].to_f]
    end
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

  def day(week_number, day_number)
    # Why do I have to subtract 4 days?!
    ((Date.today.beginning_of_year + week_number.weeks + day_number.days) - 4.days).strftime('%b %d')
  end

  def grouped_by_day(day_number, n_weeks)
    ticks.where('EXTRACT(DOW FROM time) = ? AND time > ?', day_number, n_weeks_ago(day_number, n_weeks))
      .pluck(:time, :amount)
      .group_by{ |datum| datum[0].strftime('%U').to_i }
  end

  def stacked_consecutive_days(n_days)
    # It only returns 4 days when on a weekend
    ticks.where('time > ?', ((n_days - 0).business_days.before(Date.today))).pluck(:time, :amount)
      .group_by{ |datum| datum[0].to_date }
  end

  def current_week_number
    Date.today.strftime('%U').to_i
  end

  def n_weeks_ago(day_number, n_weeks)
    today = Time.current.to_date
    if today.wday == day_number
      delta = today - n_weeks.weeks
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
