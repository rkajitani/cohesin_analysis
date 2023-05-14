#!/usr/bin/env python

import sys
from Bio import SeqIO

if len(sys.argv) < 4:
    print("usage:", sys.argv[0], "transcript.fa target_len motifi1 [modif2 ...]", file=sys.stderr)
    exit(1)

target_len = int(sys.argv[2])
motif_list = sys.argv[3:]

for rc in SeqIO.parse(sys.argv[1], "fasta"):
    if len(rc.seq) < target_len:
        continue
    target_region = rc.seq[-target_len:]
    for motif in motif_list:
        if motif in target_region:
            print(rc.id)
            break
