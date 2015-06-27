namespace :log do
  desc 'Log all intraday ticks'
  task :intraday => :environment do
    Log.new.intraday
  end
end
