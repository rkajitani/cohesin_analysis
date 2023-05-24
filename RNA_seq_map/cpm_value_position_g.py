#!/usr/bin/env python

import sys

if len(sys.argv) != 3:
    print("usage:", sys.argv[0], "vectors.tsv num_reads", file=sys.stderr)
    exit(1)

n_million_reads = float((sys.argv[2])) / 1000000

tran_dict = dict()
with open(sys.argv[1], "r") as fin:
    for l in fin:
        f = l.rstrip("\n").split("\t")
        print(f[0], "\t", "\t".join([f"{float(x) / n_million_reads:g}" for x in f[1:]]), sep="")
