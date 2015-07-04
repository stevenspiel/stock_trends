module ChartsHelper
  def historical_chart(sym)
    data = sym.historical_data
    return nil unless data
    LazyHighCharts::HighChart.new('spline') do |f|
      f.zoomType(:x)
      f.title(text: historical_title(sym))
      f.xAxis(type: 'datetime')
      f.tooltip(pointFormat: 'Price: ${point.y:.2f}')
      f.legend(enabled: false)
      f.rangeSelector({
          inputEnabled: false,
          buttonTheme: {
            fill: 'none',
            stroke: 'none',
            'stroke-width' => 0,
            r: 8,
            style: {
              color: '#21ce99',
              fontWeight: 'bold'
            },
            states: {
              hover: {
                fill: 'none',
                style: {
                  color: '#CCC',
                  cursor: 'pointer',
                }
              },
              select: {
                fill: 'none',
                style: {
                  color: '#CCC',
                }
              }
            },
            labelStyle: {
              display: 'none'
            },
            selected: 1
          }
        })
      f.series({
          type: 'area',
          name: 'Price',
          data: data,
          color: '#21ce99',
          fillColor: { linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 }, stops: [[0, '#21ce99'], [1, '#21ce99']] }
        })
      f.navigator(enabled: false)
    end
  end

  def week_day_charts(sym)
    n_weeks = 5
    (1..5).to_a.map do |day_of_week|
      data = sym.intraday_data(day_of_week, n_weeks)
      LazyHighCharts::HighChart.new('spline') do |f|
        f.title(text: Sym.week_day(day_of_week))

        data.each do |data|
          f.series(name: data[:name], data: data[:data])
        end

        f.xAxis(type: 'datetime', dateTimeLabelFormats: { hour: '%I %p', minute: '%I:%M %p' }, title: { text: nil })
        f.yAxis(labels: { formatter: "function(){ return '$' + this.value.toFixed(2) }".js_code}, title: { text: nil })
        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: 0, layout: 'vertical')
        f.tooltip(formatter: "function(){ return this.series.name + ' ' + (moment(this.x + 1000*3600*4)).format(' hh:mm') + '<br><b>$' + this.y + '</b>' }".js_code)
        # f.colors(n_days.times.map{|n| "rgba(0, 0, 0, #{ ( 1.to_f / (n + 1)**1.75 ).round(2)})" }.reverse)
        f.colors(data.size.times.map{|n| "rgba(69, 213, 161, #{ ( 1.to_f / (n + 1)**1.1 ).round(2)})" }.reverse[(data.size * -1)..-1])
        f.chart(height: 300)
        f.plotOptions({
            series: {
              lineWidth: 3,
              marker: {
                fillColor: 'none',
                lineColor: nil,
                symbol: 'circle',
                radius: 1,
                enabled: false
              }
            }
          })
      end
    end
  end

  def past_n_days_chart(sym, n_days = 5)
    LazyHighCharts::HighChart.new('spline') do |f|
      f.title(text: "Past #{n_days} Work Days")

      past_work_days = sym.past_work_days(n_days)
      past_work_days.each do |data|
        f.series(name: data[:name], data: data[:data])
      end

      f.xAxis(type: 'datetime', dateTimeLabelFormats: { hour: '%I %p', minute: '%I:%M %p' }, title: { text: nil })
      f.yAxis(labels: { formatter: "function(){ return '$' + this.value.toFixed(2) }".js_code}, title: { text: nil })
      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: 0, layout: 'vertical')
      f.tooltip(formatter: "function(){ return this.series.name + ' ' + (moment(this.x + 1000*3600*4)).format(' hh:mm') + '<br><b>$' + this.y + '</b>' }".js_code)
      f.colors(past_work_days.size.times.map{|n| "rgba(69, 213, 161, #{ ( 1.to_f / (n + 1)**1.1 ).round(2)})" }.reverse)
      f.chart(height: 300)
      f.plotOptions({
          series: {
            lineWidth: 3,
            marker: {
              fillColor: 'none',
              lineColor: nil,
              symbol: 'circle',
              radius: 1,
              enabled: false
            }
          }
        })
    end
  end
end