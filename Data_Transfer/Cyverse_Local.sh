#!/bin/bash

### USER INPUTS ----------------------------------
#Path for local directory to put files
dir="/Users/laura/Documents/CONUS/Warming_Runs/Simulation_Averages"

#PATH to Cyverse simulations
cyvdir="/iplant/home/shared/avra/CONUS_1.0/Simulations"

##Select the runs to copy
declare -a cyvrunlist=("Baseline" "2Deg_Warming" "4Deg_Warming") #Directory names on Cyverse
declare -a locrunlist=("Temp0" "Temp2" "Temp4") #local directory names These will be created if they don't exist

# List of variables to copy
declare -a varlist=("LH" "SM")

# List of run years to get
#declare -a yearlist=("4" "5" "6" "7")
declare -a yearlist=("4" "5")

#Pick whether to get daily, monthly or annual
getday=true
getmon=true
getyear=true

### End of User Inputs ---------------------------

cd $dir
nrun=${#cyvrunlist[@]}
nvar=${#varlist[@]}
nyear=${#yearlist[@]}
echo "Looping over" $nrun "runs," $nvar "variables and" $nyear "years"

#Looping over runs
for (( r=1; r<${nrun}+1; r++ ));
do
	lrun=${locrunlist[$r-1]}
	cyvrun=${cyvrunlist[$r-1]}

	#Looping over years
	for(( y=1; y<${nyear}+1; y++ ));
	do
		year=${yearlist[$y-1]}
		echo $year

		#Make a local directory for the run/year if it doesn't exist
		dtemp="./${lrun}_Year${year}"
		echo $dtemp
		mkdir $dtemp
		#cd $dtemp

		#Looping over variables
		for (( v=1; v<${nvar}+1; v++ ));
		do
			var=${varlist[$v-1]}
			echo $var

			### Daily
			if ($getday)
			then
				echo "Processing Daily"
				#Looping over months
				for day in {1..365}
				do
					#echo $day
					fin=$(printf "%s/%s/Processed_Outputs/Year%s/%s.monthly.%03d.bin" $cyvdir $cyvrun $year $var $day)
					fout=$(printf "%s/%s.daily.%03d.bin" $dtemp $var $day)
					echo "Copying $fin"
					echo "Here $fout"
					iget -KrfP $fin $fout
				done #end for day
			fi #end if getday

			### Monhtly
			if ($getmon)
			then
				echo "Processing Monthly"
				#Looping over months
				for month in {1..12}
				do
					#echo $month
	  			fin=$(printf "%s/%s/Processed_Outputs/Year%s/%s.monthly.%02d.bin" $cyvdir $cyvrun $year $var $month)
					fout=$(printf "%s/%s.monthly.%02d.bin" $dtemp $var $month)
					echo "Copying $fin"
					echo "Here $fout"
					iget -KrfP $fin $fout
				done #end for month
			fi #end if getmon

			### Yearly
			if ($getyear)
			then
				echo "Processing Yearly"
				fin=$(printf "%s/%s/Processed_Outputs/Year%s/%s.yearly.bin" $cyvdir $cyvrun $year $var)
				fout=$(printf "%s/%s.yearly.bin" $dtemp $var )
				echo "Copying $fin"
				echo "Here $fout"
				iget -KrfP $fin $fout
			fi #end if getmon

		done #end for var

	done #end for year

done #end for run
