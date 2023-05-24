#!/usr/bin/env python

import sys

if len(sys.argv) != 4:
    print("usage:", sys.argv[0], "in.bed ref_len.tsv down_len", file=sys.stderr)
    sys.exit(1)

down_len = int(sys.argv[3])

ref_len_dict = dict()
with open(sys.argv[2]) as fin:
    for line in fin:
        f = line.rstrip("\n").split("\t")
        ref_len_dict[f[0]] = int(f[1])


with open(sys.argv[1]) as fin:
    for line in fin:
        f = line.rstrip("\n").split("\t")
        f[3] += "_down"
        if f[5] == "+":
            f[1] = f[2]
            f[2] = str(int(f[2]) + down_len)
        elif f[5] == "-":
            f[2] = f[1]
            f[1] = str(int(f[1]) - down_len)
        else:
            continue
        if int(f[1]) >= 0 and int(f[2]) <= ref_len_dict[f[0]]:
            print("\t".join(f))
