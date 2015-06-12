# scripts to download new output.data and online measurements (correlators, gradient flow etc.)
# for ongoing simulations while excluding the configurations (and anything else that you might add
# to the list of exclusions

# to set up, provide space-separated lists of:
# remote servers in the form user@machine in the REMOTES variable
# some remote directories on these servers in the RDIRS variable

# you should be able to log into the remote severs via ssh key because we will
# use ssh-agent so that we only enter the password once

# the agent is killed once the transfers have been completed

#!/bin/bash

REMOTES="$HLRNB $HLRNH"
RDIRS=/gfs1/work/bbpkostr/runs/nf211
EXCLUDE='*/conf.*'

# start an ssh-agent so that we don't have to keep entering our password
eval `ssh-agent`
ssh-add

for remote in $REMOTES; do
  for rdir in $RDIRS; do
    echo "rsync --exclude="${EXCLUDE}" -av $remote:$rdir/* ."
    rsync --exclude="${EXCLUDE}" -av "$remote:$rdir/*" .
  done
done

kill $SSH_AGENT_PID

SDIR=`pwd`

putonlinetogether() {
  echo `pwd`
  echo $i putonlinetogether.sh
  putonlinetogether.sh
}

updated=""

# traverse all subdirectories
for i in `find .`; do
  if [ -d $i ]; then 
    cd $i
    nonline=`ls -1 onlinemeas.* | wc | awk '{print $1}'`
    # if subdirectory has online measurements 
    if [[ ! -z "$nonline" && $nonline -gt 0 ]]; then
      # get modification time (seconds since epoch) of last onlinemeas
      lastepoch=`stat -c %Y \`ls -1 onlinemeas.* | tail -n 1\``
      # check if we need to update piononline.dat
      if [ -e piononline.dat ]; then
        if [ $lastepoch -gt `stat -c %Y piononline.dat` ]; then
          putonlinetogether
          updated="$updated\n$i"
        fi
      else
        # if there is no piononline.dat, create it!
        putonlinetogether
        updated="$updated\n$i"
      fi
    fi
    cd $SDIR
  fi
done

echo -e $updated
