module ChartsHelper
  def historical_chart(data, sym)
    return nil unless data
    LazyHighCharts::HighChart.new('spline') do |f|
      f.zoomType(:x)
      f.title({
        text: historical_title(sym),
        style: { color: '#000000' }
      })
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
          # fillColor: { linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 }, stops: [[0, '#21ce99'], [1, '#21ce99']] }
        })
      f.navigator(enabled: false)
    end
  end

  def week_day_charts(ticks)
    grouped_by_day_of_week = ticks.group_by { |(time, _)| time.strftime('%u').to_i }
    Hash[grouped_by_day_of_week.sort].map do |day_of_week, data_points|
      grouped_by_week = data_points.group_by { |(time, _)| time.strftime('%U') }
      sorted_grouped_by_week = Hash[grouped_by_week.sort]
      data_sets = SymPresenter.highchart_data_sets(sorted_grouped_by_week)
      next unless data_sets.present?
      LazyHighCharts::HighChart.new('spline') do |f|
        f.title(text: SymPresenter.week_day(day_of_week))

        data_sets.each do |data|
          f.series(name: data[:name], data: data[:data])
        end

        f.xAxis(type: 'datetime', dateTimeLabelFormats: { hour: '%I %p', minute: '%I:%M %p' }, title: { text: nil })
        f.yAxis(labels: { formatter: "function(){ return '$' + this.value.toFixed(2) }".js_code}, title: { text: nil })
        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: 0, layout: 'vertical')
        f.tooltip(formatter: "function(){ return this.series.name + ' ' + (moment(this.x + 1000*3600*4)).format(' hh:mm') + '<br><b>$' + this.y + '</b>' }".js_code)
        # f.colors(n_days.times.map{|n| "rgba(0, 0, 0, #{ ( 1.to_f / (n + 1)**1.75 ).round(2)})" }.reverse)
        f.colors(data_sets.size.times.map{|n| "rgba(69, 213, 161, #{ ( 1.to_f / (n + 1)**1.1 ).round(2)})" }.reverse[(data_sets.size * -1)..-1])
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

  def past_n_days_chart(ticks, n_days)
    earliest_date = Date.today - (n_days + 3).days # add 3 days for possible 3 day weekends
    relevant_ticks = ticks.select { |(time, _)| time > earliest_date }
    grouped_by_day_sorted = Hash[relevant_ticks.group_by { |(time, _)| time.to_date }.to_a.last(n_days).sort] # to_a.last trims extra days
    data_sets = SymPresenter.highchart_data_sets(grouped_by_day_sorted)
    return unless data_sets.present?
    LazyHighCharts::HighChart.new('spline') do |f|
      f.title(text: "Past #{n_days} Work Days")

      data_sets.each do |data|
        f.series(name: data[:name], data: data[:data])
      end

      f.xAxis(type: 'datetime', dateTimeLabelFormats: { hour: '%I %p', minute: '%I:%M %p' }, title: { text: nil })
      f.yAxis(labels: { formatter: "function(){ return '$' + this.value.toFixed(2) }".js_code}, title: { text: nil })
      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: 0, layout: 'vertical')
      f.tooltip(formatter: "function(){ return this.series.name + ' ' + (moment(this.x + 1000*3600*4)).format(' hh:mm') + '<br><b>$' + this.y + '</b>' }".js_code)
      f.colors(data_sets.size.times.map{|n| "rgba(69, 213, 161, #{ ( 1.to_f / (n + 1)**1.1 ).round(2)})" }.reverse)
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
