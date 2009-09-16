conplot <- function(x) {
  write(x, "/tmp/tmp.dat", 1)
  system("conplot < /tmp/tmp.dat")
}
