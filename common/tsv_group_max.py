#!/usr/bin/env python

import sys
import pandas as pd

if len(sys.argv) != 3:
    print("usage:", sys.argv[0], "in.tsv group_col_index(0-based)", file=sys.stderr)
    sys.exit(1)

df = pd.read_table(sys.argv[1], header=None)
group_df = df.groupby(int(sys.argv[2])).max()
group_df.to_csv(sys.stdout, header=None, sep="\t")
