class Market < ActiveRecord::Base
  has_many :syms, dependent: :destroy
  has_many :days, through: :syms

  scope :by_importance, -> { order(:id) }

  def self.nyse; find_by_name('New York Stock Exchange'); end
  def self.nasdaq; find_by_name('NASDAQ'); end
  def self.amex; find_by_name('AMEX'); end

  def to_s
    name
  end

  def open?
    opening_time.past? && closing_time.future?
  end

  def closed?
    !open?
  end

  def last_day_curated
    read_attribute(:last_day_curated) ||
      days.order(:date).last.date ||
      'Jan 1, 1900'.to_date
  end

  private

  def closing_time
    Date.today + hour_closes.hours - Time.now.utc_offset.seconds
  end

  def opening_time
    Date.today + hour_opens.hours - Time.now.utc_offset.seconds
  end
end
