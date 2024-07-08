#!/bin/sh

awk '{
    if (NR == 1)
        b = systime()
    printf "% 6d: %s\n", systime() - b, $0
}'
