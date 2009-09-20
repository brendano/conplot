conplot <- function(x) {
  # lame: assume 'conplot' is on PATH.  R doesn't have a way for a .R file to
  # figure out its filesystem location, AFAIK.
  write(x, "/tmp/tmp.dat", 1)
  system("conplot < /tmp/tmp.dat")
}
