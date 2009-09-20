#!/usr/bin/env ruby
#
# conplot.rb -- reads a column of numbers and plots them on the console
# Main site: http://github.com/brendano/conplot
# Introduction: http://anyall.org/blog/2008/05/conplot-a-console-plotter/
# Brendan O'Connor - brenocon@gmail.com - anyall.org


require 'pp'

module ConPlot
  class Plot
    def initialize
      @x_min = nil
      @x_max = nil
      @y_min = nil
      @y_max = nil

      @x = []
      @y = []

      @plot_left_margin = 6
      
    end
    
    def console_rows
      23
    end

    def console_cols
      80
    end

    def print_console
      plot_vert_offset = 0
      plot_horiz_offset = @plot_left_margin
      plot_width =  console_cols - plot_horiz_offset
      plot_height = console_rows - plot_vert_offset

      screen = (0...plot_height).map { [' ']*plot_width }

      raise "vectors not aligned" unless @x.size == @y.size
      (0...@x.size).each do |i|
        screen_x = (@x[i] - @x_min).to_f / (@x_max - @x_min) * plot_width + plot_horiz_offset
        screen_y = (@y[i] - @y_min).to_f / (@y_max - @y_min) * plot_height + plot_vert_offset
        screen[screen_y.to_i][screen_x.to_i] = 'o'
      end

      add_vert_ticks(screen, plot_height)
      add_horiz_ticks(screen, plot_width, plot_horiz_offset)

      screen.reverse.each do |row|
        # p row
        puts row.join("")
      end
    end

    # should special case when x's are all sequential integers or so
    def add_horiz_ticks(screen, plot_width, plot_horiz_offset)
      screen_tick_points = [ [0,:left], [plot_width-1,:right] ]
      screen_tick_points.each do |screen_tick_x, justify|
        x_range = @x_max - @x_min
        tick_point = (screen_tick_x.to_f / screen[0].size) * x_range + @x_min
        mark_str = reasonable_num_str(tick_point, x_range)
        screen_x = plot_horiz_offset + screen_tick_x
        landing_spots = (justify==:left) ? (screen_x .. (screen_x+mark_str.size)).to_a :
          ( (screen_x - mark_str.size) .. screen_x).to_a
        (0...mark_str.size).each do |i|
          screen[0][ landing_spots[i] ] = [ mark_str[i] ].pack("U*")
        end
      end
    end

    def reasonable_num_str(tick_point, range)
      s= "%f"   % tick_point if range <= 0.5
      s= "%.3f" % tick_point if range > 0.5
      s= "%.2f" % tick_point if range > 3
      s= "%.1f" % tick_point if range > 30
      s= "%.0f" % tick_point if range > 3000
      s
    end

    def add_vert_ticks(screen, plot_height)
      # tick_points = [@y_min, @y_min + (@y_max-@y_min)/2,  @y_max]
      # tick_points.each do |tick_point|
      screen_tick_points = [0, (screen.size/4).to_i, (screen.size/2).to_i, (screen.size*3/4).to_i, screen.size-1]
      screen_tick_points.each do |screen_tick_y|
        y_range = @y_max - @y_min
        tick_point = (screen_tick_y.to_f / screen.size) * y_range + @y_min
        mark_str = reasonable_num_str(tick_point, y_range)
        (0...mark_str.size).each do |i|
          screen[screen_tick_y.to_i][i] = [mark_str[i]].pack("U*")
        end
      end
    end

        # screen_tick_y = (tick_point - @y_min).to_f / (@y_max-@y_min) * (plot_height-1)

    def set_and_adjust_y(y)
      @y = y
      @x = (0...y.size).to_a
      range = (y.max - y.min).abs
      @y_min = y.min - range*0.05
      @y_max = y.max + range*0.05
      @x_min = 0
      @x_max = y.size - 1
    end

    def set_and_adjust_scatterplot( xy_pairs )
      raise "not implemented"
    end
  end
end


if $0 == __FILE__
  numbers = $stdin.readlines.map do |l| 
    if l =~ /^\s*$/
      nil
    else
      begin;  l.to_f
      rescue; nil
      end
    end
  end.compact
  if numbers.empty?
    puts "No inputs."
    exit
  end
  plot = ConPlot::Plot.new
  plot.set_and_adjust_y(numbers)
  plot.print_console
end
