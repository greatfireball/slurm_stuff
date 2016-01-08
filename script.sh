#!/bin/bash

/usr/bin/squeue \
    --clusters=serial \
    --format="%i %P %j %u %T %M %l %D %R %Q %p" | \
    grep serial_ | sort | column -t | \
    perl -e '
          @dat=<>; 
          @dat=map {[split /[\t ]+/, $_] } @dat; 

          @dat = sort {
             $b->[4] cmp $a->[4] ||
             $b->[10] <=> $a->[10]
          } @dat; 

          foreach (@dat) { 
             print join("\t", @{$_}); 
          }' | \
    column -t | less
