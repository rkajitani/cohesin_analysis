#!/usr/bin/env python

import sys
import math
import numpy as np

if len(sys.argv) != 3:
    print("usage:", sys.argv[0], "vectors.tsv max_vec_size", file=sys.stderr)
    exit(1)

max_size = int(sys.argv[2])

tran_dict = dict() 
with open(sys.argv[1], "r") as fin:
    for l in fin:
        f = l.rstrip("\n").split("\t")
        if len(f) - 1 < max_size:
            arr = np.full(max_size, np.nan, dtype=float)
            arr[0:len(f) - 1] = np.array(f[1:], dtype=float)
            tran_dict[f[0]] = arr
        else:
            tran_dict[f[0]] = np.array(f[1:max_size+1], dtype=float)

n_row = len(tran_dict)
mat = np.full((n_row, max_size), np.nan)

i = 0
for tran_id, tran_vec in tran_dict.items():
    tran_vec[tran_vec < 0] = np.nan
    mat[i, :] = tran_vec
    i += 1

col_means = np.nanmean(mat, axis=0)
for i in range(0, max_size):
    if not np.isnan(col_means[i]):
        print("mean", i + 1, col_means[i], sep="\t")

col_sd = np.nanstd(mat, axis=0)
for i in range(0, max_size):
    if not np.isnan(col_sd[i]):
        print("SD", i + 1, col_sd[i], sep="\t")
