namespace :log do
  desc 'Log all intraday ticks'
  task :intraday => :environment do
    Log.new.intraday
  end

  desc 'Log all historical data'
  task :historical => :environment do
    Log.new.historical
  end
end
