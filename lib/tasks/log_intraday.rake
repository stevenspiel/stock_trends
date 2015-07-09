namespace :log do
  desc 'Log all intraday ticks'
  task :intraday => :environment do
    Log.new.intraday
    Rails.cache.clear
  end
end
