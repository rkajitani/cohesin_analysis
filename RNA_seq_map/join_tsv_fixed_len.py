#!/usr/bin/env python

import sys

if len(sys.argv) != 4:
    print("usage:", sys.argv[0], "left.tsv right.tsv length", file=sys.stderr)
    sys.exit(1)

window_len = int(sys.argv[3])
left_dict = dict()

with open(sys.argv[1]) as fin:
    for line in fin:
        f = line.rstrip("\n").split("\t")
        if len(f) - 1 < window_len:
            continue
        left_dict[f[0]] = "\t".join(f[(len(f) - window_len + 1):len(f)])

with open(sys.argv[2]) as fin:
    for line in fin:
        f = line.rstrip("\n").split("\t")
        if len(f) - 1 < window_len or f[0] not in left_dict:
            continue
        print(f[0], left_dict[f[0]], "\t".join(f[1:(window_len + 1)]), sep="\t")
