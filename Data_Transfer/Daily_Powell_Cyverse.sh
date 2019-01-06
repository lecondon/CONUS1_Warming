#!/bin/bash

#Local directory where the tars will be placed
dir1="T0Y6_tarxfer"
#Name of directory on Powell where binary files sit
#NOTE: See Powell_Run_List.txt for directory list 
dir="averages-Temp-0-Year-3-CHECK"
#Directory on Cyverse where files should be transferred to
icd  /iplant/home/shared/avra/CONUS_1.0/Simulations/Baseline/Processed_Outputs/Year6
var="LH"

mkdir $dir1
cd $dir1

for month in {0..9}
do
  echo $month
  cd ../$dir
  tar -cvzf ../$dir1/$var.daily.$month.tar $var.daily*$month.bin
  pwd
  cd ../$dir1
  iput -vrfP $var.daily.$month.tar
  ibun -xf $var.daily.$month.tar .
  irm $var.daily.$month.tar
done
echo "DONE!"
