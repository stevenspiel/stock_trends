class Curator
  def self.run!(market)
    new(market).run
  end

  def initialize(market)
    ActiveRecord::Base.logger = nil # suppress sql output
    @market = market
    @last_day_curated = market.last_day_curated
    @today = Date.today
  end

  def run
    (@last_day_curated..@today).each do |date|
      puts "...............#{date}..............."
      next unless any_existing_data_for_day?(date) # ignore weekends and holidays
      remove_empty_days(date)
      @market.syms.enabled.find_each do |sym|
        print "#{sym.padded}"
        day = Day.find_or_create_by(sym: sym, date: date)
        if day.ticks.count >= 2 # endpoints are all a Day needs to be viable
          print 'Valid'
        else
          print 'Curating...'
          curate_day(sym, day)
        end
        puts # separator
      end
    end
    @market.update_column(:last_day_curated, @today)
  end

  private

  def curate_day(sym, day)
    most_recent_tick = sym.ticks.where('time < ?', day.date.to_datetime).order(:time).last
    return print 'No ticks' unless most_recent_tick.present?
    most_recent_price = most_recent_tick.amount
    day.add_endpoints(most_recent_price)
    day.save
    print 'Success'
  end

  def any_existing_data_for_day?(date)
    @market.days.find_by_date(date).present?
  end

  def remove_empty_days(date)
    scope = @market.days.where(date: date)
    empty_days = scope.without_ticks
    return unless empty_days.any?
    days_with_data = scope.with_ticks
    return if days_with_data.any?
    empty_days.destroy_all
  end
end
