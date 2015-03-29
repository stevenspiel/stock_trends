class Market < ActiveRecord::Base
  has_many :syms, dependent: :destroy

  scope :by_importance, -> { order(:id) }

  def to_s
    name
  end

  def open?
    opening_time.past? && closing_time.future?
  end

  def closed?
    !open?
  end

  private

  def closing_time
    Date.today + hour_closes.hours - Time.now.utc_offset.seconds
  end

  def opening_time
    Date.today + hour_opens.hours - Time.now.utc_offset.seconds
  end
end
