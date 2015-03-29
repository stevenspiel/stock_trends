class HistoricalDatum < ActiveRecord::Base
  belongs_to :sym

  scope :logged, -> { where(historical_data_logged: true) }
end
