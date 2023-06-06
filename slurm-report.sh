#!/bin/bash
#
# Hacked together by Ali Hassani (@alihassanijr)

JOBIDS=$(sacct -n --allusers --format=JobID  | /usr/bin/grep -x "[0-9]*[^.]*")

getarg () {
  inp=$1
  regx=$2
  repl=$3
  defaultvalue=$4
  tmp=$(echo $inp | /usr/bin/grep -o "${regx}")
  if [[ -z $tmp ]]; then
    out=$defaultvalue
  else
    out=${tmp/${repl}/}
  fi
  echo $out
}

#echo -e "USER \t\t\t GPUS \t\t\t NODES \t\t\t QUEUE"
printf "%10s %30s %5s %5s %30s %20s  \n" "JOBID" "USER" "# GPUS" "# NODES" "QUEUE" "STATE"

for job in ${JOBIDS[@]}; do
  jobinfo=$(scontrol show job $job -o  2>&1)
  haserr=$(echo $jobinfo | /usr/bin/grep 'error')
  if [[ -z $haserr ]]; then
    numgpus=$(getarg "$jobinfo" 'gres/gpu=[0-9]*' 'gres\/gpu=' 0)
    numnodes=$(getarg "$jobinfo" 'node=[0-9]*' 'node=' 0)
    partition=$(getarg "$jobinfo" 'Partition=[a-zA-Z]*' 'Partition=' "Unknown")
    user=$(getarg "$jobinfo" 'UserId=[^ ]*' 'UserId=' "Unknown")
    jobstate=$(getarg "$jobinfo" 'JobState=[^ ]*' 'JobState=' "Unknown")

    #echo -e "$user \t\t\t $numgpus \t\t\t $numnodes \t\t\t $partition"
    printf "%10s %30s %5s %5s %30s %20s \n" $job $user $numgpus $numnodes $partition $jobstate
  fi
done;
