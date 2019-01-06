#!/bin/bash

### USER INPUTS ----------------------------------
#Path for local directory to put files
dir="/Users/laura/Documents/CONUS/Warming_Runs/Simulation_Averages"

##Select the runs to copy
declare -a cyvrunlist=("Baseline" "2Deg_Warming" "4Deg_Warming") #Directory names on Cyverse
declare -a locrunlist=("Temp0" "Temp2" "Temp4") #local directory names These will be created if they don't exist

# List of variables to copy
declare -a varlist=("LH" "SM")

# List of run years to get
declare -a yearlist=("4" "5" "6")

### End of User Inputs ---------------------------

cd $dir
nrun=${#cyvrunlist[@]}
nvar=${#varlist[@]}
nyear=${#yearlist[@]}
echo "Looping over" $nrun "runs," $nvar "variables and" $nyear "years"

# use for loop to read all values and indexes
for (( r=1; r<${nrun}+1; r++ ));
do
	for(( y=1; y<${nrun}+1; y++ ))
	do
		run=${locrunlist[r-1]}
		year=${yearlist[$y-1]}
		dtemp="./${run}_Year${year}"
		mkdir $dtemp
		cd $dtemp
		pwd
		cd ../
		echo $dtemp #$run $year
  	#echo $r " / " ${nrun} " : " ${cyvrunlist[$r-1]} " : " ${locrunlist[$r-1]}
	done
done




#for run in "$runlist"
#do
#	echo "$run"
#done


#
##pwd
#idir="/iplant/home/shared/avra/CONUS_1.0/Simulations"
#fname='SM.yearly.bin'
#
#for year in {4..7}
#do
#  #baseline
#	fin="$idir/Baseline/Processed_Outputs/Year$year/$fname"
#  fout="./Temp0_Year$year/$fname"
#  echo $fin
#  echo $fout
#	#iget -KvrfP $fin $fout
#
#  #temp2
#  fin="$idir/2Deg_Warming/Processed_Outputs/Year$year/$fname"
#  fout="./Temp2_Year$year/$fname"
#  echo $fin
#  echo $fout
#  #iget -KvrfP $fin $fout
#
#  #temp4
#  fin="$idir/4Deg_Warming/Processed_Outputs/Year$year/$fname"
#  fout="./Temp4_Year$year/$fname"
#  echo $fin
#  echo $fout
#  #iget -KvrfP $fin $fout
#done
