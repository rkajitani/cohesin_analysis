#!/usr/bin/env python

import sys
import subprocess as sp

if len(sys.argv) != 2:
    print("usage:", sys.argv[0], "in.bam", file=sys.stderr)
    sys.exit(1)

cmd = f"samtools view -F 2308 {sys.argv[1]}"
n_sense = 0
n_antisense = 0
with sp.Popen(cmd, shell=True, stdout=sp.PIPE) as proc:
    for ln in iter(proc.stdout.readline, b''):
        ln = ln.decode('utf-8')
        f = ln.split('\t')
        flag = int(f[1])
        if flag & 64:
            if flag & 16:
                n_sense += 1
            else:
                n_antisense += 1
        if flag & 128:
            if flag & 16:
                n_antisense += 1
            else:
                n_sense += 1

print(n_sense, n_antisense, sep='\t')
