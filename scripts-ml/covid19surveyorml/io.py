# -*- coding: utf-8 -*-

import csv


def read_csv(input_buffer):
    reader = csv.reader(input_buffer)
    for d in reader:
        if len(d) <= 1:
            continue
        elif len(d) > 2:
            yield (','.join(d[:-1]), d[-1].strip())
        else:
            yield (d[0], d[1].strip())
