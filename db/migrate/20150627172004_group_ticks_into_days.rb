class Sym < ActiveRecord::Base
  has_many :days
  has_many :ticks # changes after migration completes
end

class Day < ActiveRecord::Base
  belongs_to :sym
  has_many :ticks
end

class Tick < ActiveRecord::Base
  belongs_to :day
end


class GroupTicksIntoDays < ActiveRecord::Migration
  include ActionView::Helpers::DateHelper

  def up
    # add_column :ticks, :day_id, :integer, index: true
    
    completed = 0
    total_number_of_syms = Sym.count
    total_seconds_elapsed = 0
    Sym.all.find_each do |sym|
      start = Time.now
      all_sym_ticks = sym.ticks
      ticks_size = all_sym_ticks.count
      grouped_tick_ids = sym.ticks.reorder('').select("id, to_char(time, 'YYYY-MM-DD') as date").group_by(&:date)
      grouped_tick_ids.each do |day, ticks|
        day = Day.create(sym: sym, date: day)
        Tick.where(id: ticks.map(&:id)).update_all(day_id: day.id)
      end

      completed += 1
      finish = Time.now
      seconds_elapsed = (finish - start)
      total_seconds_elapsed += seconds_elapsed

      puts statistics_for_output(completed, total_number_of_syms, total_seconds_elapsed, seconds_elapsed, ticks_size)
    end

    remove_column :ticks, :sym_id
    change_column_null :ticks, :day_id, true
  end

  def down
    raise IrreversibleMigration
  end

  private

  def statistics_for_output(completed, total_number_of_syms, total_seconds_elapsed, seconds_elapsed, ticks_size)
    percent_complete = ((completed * 100) / total_number_of_syms.to_f)
    ticks_per_second = (ticks_size / seconds_elapsed).round
    seconds_to_complete = (total_seconds_elapsed * 100) / percent_complete
    seconds_remaining = seconds_to_complete - total_seconds_elapsed

    "#{percent_complete.round(2)}%: #{seconds_elapsed.round}s" +
    " (#{ticks_size} ticks)" +
    " - #{ticks_per_second} ticks per second" +
    " - #{distance_of_time_in_words(seconds_remaining)} remaining"
  end
end
