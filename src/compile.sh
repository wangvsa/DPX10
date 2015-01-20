#!/bin/bash


# when running
#x10c++ -O -NO_CHECKS *.x10 demo/*.x10 demo/*/*.x10 tada/*.x10 tada/dag/*.x10 tada/util/*.x10

# when developing
x10c++ *.x10 demo/*.x10 demo/*/*.x10 tada/*.x10 tada/dag/*.x10 tada/util/*.x10 -VERBOSE_CHECKS

rm *.cc *.h demo/*.h demo/*.cc demo/*/*.h demo/*/*.cc tada/*.cc tada/*.h tada/*/*.h tada/*/*.cc

#export X10_NPLACES=4
#export X10_NTHREADS=2
#export X10_CONGRUENT_HUGE=true
