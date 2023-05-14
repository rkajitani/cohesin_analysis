#!/usr/bin/env python

import sys
import re
from collections import defaultdict

if len(sys.argv) != 2:
    print("usage:", sys.argv[0], "in.gtf", file=sys.stderr)
    exit(1)

class tran_info:
    def __init__(self):
        self.chr = str()
        self.gene_id = str()
        self.start = int()
        self.end = int()
        self.strand = str()
        self.exon_pos = list()

tran_dict = defaultdict(tran_info)
gene_re = re.compile(r'gene_id "(\S+)"')
tran_re = re.compile(r'transcript_id "(\S+)"')
with open(sys.argv[1], "r") as fin:
    for l in fin:
        if len(l) == 0 or l[0] == "#":
            continue
        f = l.rstrip("\n").split("\t")
        if len(f) < 9:
            continue
        if f[2] == "transcript":
            gene_m = gene_re.search(f[8])
            tran_m = tran_re.search(f[8])
            if not (gene_m and tran_m):
                continue
            tran_id = tran_m.group(1)
            tran_dict[tran_id].chr = f[0]
            tran_dict[tran_id].gene_id = gene_m.group(1)
            tran_dict[tran_id].start = int(f[3])
            tran_dict[tran_id].end = int(f[4])
            tran_dict[tran_id].strand = f[6]
        elif f[2] == "exon":
            tran_m = tran_re.search(f[8])
            if not tran_m:
                continue
            tran_id = tran_m.group(1)
            tran_dict[tran_id].exon_pos.append(int(f[3]))
            tran_dict[tran_id].exon_pos.append(int(f[4]))

for tran_id, tran_info in tran_dict.items():
    sorted_pos = sorted(tran_info.exon_pos)
    if len(sorted_pos) % 2 != 0:
        continue
    if tran_info.strand == "+":
        for i in range(1, len(sorted_pos) - 1, 2):
            intron_len = sorted_pos[i+1] - sorted_pos[i] - 1
            print(f"{tran_info.chr}-{sorted_pos[i]}-{sorted_pos[i+1] - 1}-{tran_info.gene_id}-{intron_len}\t", end="")
            print(sorted_pos[i] - tran_info.start + 1, i // 2 + 1, tran_info.chr, tran_info.strand, sorted_pos[i], sorted_pos[i+1] - 1, tran_info.gene_id, tran_id, sep="\t")
    elif tran_info.strand == "-":
        for i in range(1, len(sorted_pos) - 1, 2):
            intron_len = sorted_pos[i+1] - sorted_pos[i] - 1
            print(f"{tran_info.chr}-{sorted_pos[i]}-{sorted_pos[i+1] - 1}-{tran_info.gene_id}-{intron_len}\t", end="")
            print(tran_info.end - sorted_pos[i+1] + 1, (len(sorted_pos) - 1) // 2 -  i // 2, tran_info.chr, tran_info.strand, sorted_pos[i], sorted_pos[i+1] - 1, tran_info.gene_id, tran_id, sep="\t")
