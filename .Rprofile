.First <- function() {
       options(digits=5, length=999)         # custom numbers and printout
       # par(pch = "+")                        # plotting character
       source(file.path(Sys.getenv("HOME"), "sandbox", "r", "mystuff.R"))
                                             # my personal functions
       library(MASS)                         # attach a package
     }

# library(xterm256)

.Last <- function() {
       graphics.off()                        # a small safety measure.
       cat(paste(date(),"\nAdios\n"))        # Is it time for lunch?
     }

# vim:set filetype=r textwidth=80 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:
