#!/usr/bin/env python
# designed for python2.5 i think
from __future__ import division
import sys,os


# crazy stuff to get current terminal size, from http://pdos.csail.mit.edu/~cblake/cls/cls.py
# sadly, the simple `stty -a` doesn't work because it wants to look at the
# stdin to learn the terminal device, but that's occupied

def ioctl_GWINSZ(fd):                  #### TABULATION FUNCTIONS
    try:                                ### Discover terminal width
        import fcntl, termios, struct, os
        cr = struct.unpack('hh', fcntl.ioctl(fd, termios.TIOCGWINSZ, '1234'))
    except:
        return None
    return cr

def terminal_size():                    ### decide on *some* terminal size
    cr = ioctl_GWINSZ(0) or ioctl_GWINSZ(1) or ioctl_GWINSZ(2)  # try open fds
    if not cr:                                                  # ...then ctty
        try:
            fd = os.open(os.ctermid(), os.O_RDONLY)
            cr = ioctl_GWINSZ(fd)
            os.close(fd)
        except:
            pass
    if not cr:                            # env vars or finally defaults
        try:
            cr = (env['LINES'], env['COLUMNS'])
        except:
            cr = (25, 80)
    return int(cr[1]), int(cr[0])         # reverse rows, cols

######################

class Plot:
  def __init__(_):
    _.x_min = _.x_max = _.y_min = _.y_max = None
    _.x = []
    _.y = []
    _.plot_left_margin = 6
    _.find_console_dimensions()

  def find_console_dimensions(self):
    self.console_cols, self.console_rows = (80,25)
    self.console_rows -= 3   # compensate for shell prompt room
#     self.console_cols, self.console_rows = terminal_size()
#     print (self.console_rows,self.console_cols)
#     if self.console_rows > 25:
#       self.console_rows = 25 + int(0.5*(self.console_rows - 25))

  def print_console(_):
    bot_mar = 1
    left_mar = _.plot_left_margin
    plot_width =  _.console_cols - left_mar
    plot_height = _.console_rows - bot_mar

    print (_.console_rows, _.console_cols)
    screen = [[' ']*_.console_cols for x in range(_.console_rows)]

    assert len(_.x) == len(_.y), "vectors not aligned"
    xdenom = (_.x_max - _.x_min)
    ydenom = (_.y_max - _.y_min)
    for i in range(len(_.x)):
      screen_x = (_.x[i] - _.x_min) / xdenom * (plot_width-1) + left_mar
      screen_y = (_.y[i] - _.y_min) / ydenom * (plot_height-1) + bot_mar
      #screen_y = min(screen_y, _.console_rows-1)  # not quite right
      #print screen_y,screen_x
      screen[int(round(screen_y))][int(round(screen_x))] = 'o'
    _.add_vert_ticks(screen)
    _.add_horiz_ticks(screen, plot_width, left_mar)
    for row in reversed(screen):
      print "".join(row)

  def add_vert_ticks(_,screen):
    fmt = lambda x: ("%.4g" % x) if x>=0 else ("%.3g" % x)
    screen[-1][0:5] = "%5s" % fmt(_.y_max) 
    screen[1][0:5]  = "%5s" % fmt(_.y_min)
    bot_mar = 1
    plot_height = _.console_rows - bot_mar
    for ypos in (0.25, .5, .75):
      ydenom = (_.y_max - _.y_min)
      y = _.y_min + ypos*ydenom
      screen_y = (y - _.y_min) / ydenom * (plot_height-1) + bot_mar
      screen[int(round(screen_y))][:5] = "%5s" % fmt(y)
    #screen[0][0]='_'
    #screen[0][1]='|'
  def add_horiz_ticks(self, screen, plot_width, left_mar):
    s = str(self.x_max)
    print repr(s)
    screen[0][-len(s):] = s
  def set_and_adjust_y(self, y):
    self.y = y
    self.x = range(1, len(y)+1)
    yrange = max(y) - min(y)
    self.y_min = min(y) #- .02*yrange
    self.y_max = max(y) #+ .02*yrange
    self.x_min = min(self.x)
    self.x_max = max(self.x)
  def set_and_adjust_scatterplot(self, xy_pairs):
    raise Exception("not implemented yet, but easy to do!")


if __name__=='__main__':
  import sys,os
  numbers = []
  for line in sys.stdin:
    if line.strip() == "": continue
    if len(line.split()) == 1:
      y = float(line)
      numbers.append(y)
    if len(line.split()) >= 2:
      raise Exception("single column please")
  plot = Plot()
  plot.set_and_adjust_y(numbers)
  plot.print_console()

