#!/usr/bin/python

# based on www.hep.ph.ic.ac.uk/~dbauer/grid/qstat.html

import xml.dom.minidom
import os
import sys, getopt
import string
import pwd

all_users=[]

opts, args = getopt.getopt(sys.argv,"a")

for arg in args:
  if arg == '-a':
    all_users=1
   
def get_username():
  return pwd.getpwuid( os.getuid() )[ 0 ]

if all_users:
  f=os.popen('qstat -xml -r')
else:
  # get jobs by current user in xml format
  f=os.popen('qstat -xml -r -u ' + get_username() )

dom=xml.dom.minidom.parse(f)

jobs=dom.getElementsByTagName('job_info')
run=jobs[0]
runjobs=run.getElementsByTagName('job_list')

# for exploratory purposes we can pipe the output to an xml file 
# and open it in a web browser for inspection
#print dom.toxml()

def fakeqstat(joblist):
  cores=0
  for r in joblist:
    jobname=r.getElementsByTagName('JB_name')[0].childNodes[0].data
    jobown=r.getElementsByTagName('JB_owner')[0].childNodes[0].data
    jobstate=r.getElementsByTagName('state')[0].childNodes[0].data
    jobnum=r.getElementsByTagName('JB_job_number')[0].childNodes[0].data
    jobpe="1"
    pename=""
    queuename=""
    # for jobs in the standard queue there is no PE request by default, so we need to test
    # if this tag exists
    temp=r.getElementsByTagName('requested_pe')
    if temp:
      jobpe=temp[0].childNodes[0].data
      pename=temp[0].attributes["name"].value
    temp=r.getElementsByTagName('queue_name')
    if jobstate == 'r' or jobstate == 'Rr' :
      cores = int(cores) + int(jobpe)
    print  jobnum.ljust(8), ' ', jobstate.ljust(4), ' ', pename.ljust(4), ' ', jobpe.ljust(4) , ' ', jobown.ljust(8), ' ', jobname.ljust(86)
  print "Cores in use: ", cores


fakeqstat(runjobs)
