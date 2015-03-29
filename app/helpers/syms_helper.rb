module SymsHelper
  def sym_info(sym)
    "#{sym.volatility.round(4)}% volatility"
  end

  def sym_title(sym)
    "#{sym.name} #{number_to_currency sym.current_price}"
  end

  def historical_chart(sym)
    data = sym.historical_data
    return nil unless data
    LazyHighCharts::HighChart.new('spline') do |f|
      f.zoomType(:x)
      f.title(text: historical_title(sym))
      f.xAxis(type: 'datetime')
      f.legend(enabled: false)
      f.series({
          type: 'area',
          name: 'Price',
          data: data
        })
    end
  end

  def week_day_charts(sym)
    (1..5).to_a.map do |day_of_week|
      data = sym.intraday_data(day_of_week)
      LazyHighCharts::HighChart.new('spline') do |f|
        f.title(text: Sym.week_day(day_of_week))

        data.each do |data|
          f.series(name: data[:name], data: data[:data])
        end

        f.xAxis(type: 'datetime')
        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
        f.colors(%w(#EEEEEE #DDDDDD #CCCCCC #999999 #000000)[(data.size * -1)..-1])
        f.chart(height: 300)
      end
    end
  end

  def past_n_days_chart(sym, n_days = 5)
    LazyHighCharts::HighChart.new('spline') do |f|
      f.title(text: "Past #{n_days} Work Days")

      sym.past_work_days(n_days).each do |data|
        f.series(name: data[:name], data: data[:data])
      end

      f.xAxis(type: 'datetime')
      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
      f.colors(%w(#EEEEEE #DDDDDD #CCCCCC #999999 #000000))
      f.chart(height: 300)
    end
  end

  def historical_title(sym)
    dates = sym.min_and_max_historical_dates
    min = dates[:min].present? ? dates[:min].strftime('%Y') : '?'
    max = dates[:max].present? ? dates[:max].strftime('%Y') : '?'
    "#{min} - #{max}"
  end
end
