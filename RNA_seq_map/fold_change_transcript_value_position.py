#!/usr/bin/env python

import sys
import math
import numpy as np

if len(sys.argv) != 5:
    print("usage:", sys.argv[0], "val_pos_vec1.tsv val_pos_vec2.tsv num_bin pesudocount", file=sys.stderr)
    exit(1)

n_bin = int(sys.argv[3])
pseudocount = float(sys.argv[4])

tran_dict = [dict() for m in range(0, 2)]
for m in range(0, 2):
    with open(sys.argv[m + 1], "r") as fin:
        for l in fin:
            f = l.rstrip("\n").split("\t")
            tran_dict[m][f[0]] = np.array(f[1:n_bin+1], dtype=float)

tran_id_set = (set(tran_dict[0].keys()) & set(tran_dict[1].keys()))
for tran_id in tran_id_set:
    tran_vec0 = tran_dict[0][tran_id]
    tran_vec1 = tran_dict[1][tran_id]
    vec = np.full(n_bin, np.nan)
    for j in range(0, n_bin):
        if (tran_vec1[j] != np.nan and (tran_vec1[j] + pseudocount) != 0 and tran_vec0[j] != np.nan and (tran_vec0[j] + pseudocount) != 0):
            vec[j] = (tran_vec1[j] + pseudocount) / (tran_vec0[j] + pseudocount)
    print(tran_id, "\t".join([format(x, ".6f") for x in vec]), sep="\t")
