# Data Transfer Tools
This folder contains example scripts for transferring data on and off of Cyverse

### 1. Daily_Powell_Cyverse.sh
  For transferring daily bin files from Powell to Cyverse. This script puts the daily files into 10 separate tars before transferring in order to stay below the 2GB file size limit. User needs to specify the variable of interest, the source directory on Powell and the target directory on Cyverse. Refer to Powell_Run_List.txt for a list of run directory files. Also note this script is setup to be run from one directory above where the averages sit on Powell.

### 2. Cyverse_Local.sh
  For transferring files from Cyverse to a local machine.  The user can specify a list of variables, runs and years to get and can select whether to get daily, monthly or annual. 

## Still to do:
### Monthly and yearly Powell_Cyverse Examples
