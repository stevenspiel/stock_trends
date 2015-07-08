class SymPresenter
  WEEK_DAYS = %w(Sun Mon Tue Wed Thur Fri Sat)

  def self.week_day(n)
    WEEK_DAYS[n]
  end

  def self.highchart_data_sets(data)
    return unless data.present?
    last_day_of_set = data.values.last.first[0].to_date
    data.map do |_, data_points|
      {
        name: data_points.first[0].strftime('%b %d'),
        data: data_points.map { |(time, amount)| [offset_date(time, last_day_of_set).to_unix, amount.to_f] }
      }
    end
  end

  def self.offset_date(original_date, new_date)
    difference_in_days = new_date - original_date.to_date
    (original_date + difference_in_days.days)
  end
end
