#!/usr/bin/env python

import sys
import os


def mk_list():

    input_args = ""
    for i in sys.argv:
        input_args = input_args + " " + i

    input_args = list(dict.fromkeys(input_args.split(" ")))

    del input_args[0]
    del input_args[0]
    input_args.sort()

    return input_args

to_print = mk_list()
print('[ %s ]' % ' '.join(map(str, to_print)))
