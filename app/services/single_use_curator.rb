class SingleUseCurator
  def self.run!
    new.run
  end

  def initialize
    ActiveRecord::Base.logger = nil # suppress sql output
    @q = Q.new
  end

  def run
    Sym.includes(:ticks).ordered.find_each do |sym|
      # disable low-producing syms
      next if sym.ticks.count < 30 && sym.update_attribute(:disabled, true)

      # re-log historical data if needed
      if sym.historical_datums.count < 30
        data = @q.historical_data(sym)
        if data.respond_to?(:readlines) && data.readlines.size > 30
          print "Logging historical data for #{sym}..."
          sym.historical_datums.delete_all
          @q.build_and_save_data(sym, data)
          puts 'Success'
        end
      end
    end
  end
end
