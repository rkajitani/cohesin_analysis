#!/usr/bin/env python

import sys
import re

if len(sys.argv) != 2:
    print("usage:", sys.argv[0], "annot.gtf", file=sys.stderr)
    sys.exit(1)

gene_re = re.compile(r'gene_id "([^"]*)"')
tts_dict = dict()
with open(sys.argv[1]) as fin:
    gene_id = str()
    for ln in fin:
        if len(ln) == 0 or ln[0] == "#":
            continue
        f = ln.rstrip("\n").split("\t")
        if len(f) >= 9 and f[2] == "gene":
            m = gene_re.search(f[8])
            if m:
                gene_id = m.group(1)
            else:
                continue

            if f[6] == "+":
                tts_dict[gene_id] = int(f[4])
            else:
                tts_dict[gene_id] = int(f[3])

trans_re = re.compile(r'transcript_id "([^"]*)"')
with open(sys.argv[1]) as fin:
    gene_id = str()
    trans_id = str()
    for ln in fin:
        if len(ln) == 0 or ln[0] == "#":
            continue
        f = ln.rstrip("\n").split("\t")
        if len(f) >= 9 and f[2] == "transcript":
            m = gene_re.search(f[8])
            if m:
                gene_id = m.group(1)
            else:
                continue
            if gene_id not in tts_dict:
                continue

            m = trans_re.search(f[8])
            if m:
                trans_id = m.group(1)
            else:
                continue

            if f[6] == "+":
                if int(f[4]) == tts_dict[gene_id]:
                    print(trans_id, gene_id, sep="\t")
            else:
                if int(f[3]) == tts_dict[gene_id]:
                    print(trans_id, gene_id, sep="\t")
