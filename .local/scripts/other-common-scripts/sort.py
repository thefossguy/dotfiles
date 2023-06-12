#!/usr/bin/env python

import sys
import os

INPUT_STREAM = os.fstat(0)
OUTPUT_STREAM = os.fstat(1)

unsorted = ""

if len(sys.argv) > 1:
    # accept the input as command line arguments
    for argument in sys.argv:
        unsorted = unsorted + " " + argument
    unsorted = list(dict.fromkeys(unsorted.split(" ")))
    del unsorted[0] # remove the executable name
    del unsorted[0] # remove the space added by the above `.split()`
    unsorted.sort()
    print('[ %s ]' % ' '.join(map(str, unsorted)))
else:
    # accept input from STDIN
    for line in sys.stdin:
        line = line.strip()
        unsorted = unsorted + " " + line
    unsorted = list(dict.fromkeys(unsorted.split(" ")))
    del unsorted[0] # remove the space added by the above `.split()`
    unsorted.sort()
    print('%s' % ' '.join(map(str, unsorted)))
