#!/bin/bash

if [ $# -ne 3 ]; then
	echo $0 script.sh num_threads job_name
	exit 0
fi

queue=sge100.q

qsub -R y -S /bin/bash -o qsub.stdout -e qsub.stderr -q $queue -V -cwd -pe smp $2 -N $3 $1
