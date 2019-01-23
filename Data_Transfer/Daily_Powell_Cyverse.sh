

#Local directory where the tars will be placed
#dir1="T0Y6_tarxfer"
dir1="T15Y4_tarxfer"
#Name of directory on Powell where binary files sit
#NOTE: See Powell_Run_List.txt for directory list
dir="averages-Temp-0-Year-3-CHECK"
dir="averages-Temp-1.5-Year-4"
#Directory on Cyverse where files should be transferred to
#icd  /iplant/home/shared/avra/CONUS_1.0/Simulations/Baseline/Processed_Outputs/Year6
icd  /iplant/home/shared/avra/CONUS_1.0/Simulations/1.5Deg_Warming/Processed_Outputs/Year4
var="LH"

mkdir $dir1
cd $dir1

for end in {0..9}
do
  echo $month
  cd ../$dir
  tar -cvzf ../$dir1/$var.daily.$end.tar $var.daily*$end.bin
  pwd
  cd ../$dir1
  iput -vrfP $var.daily.$end.tar
  ibun -xf $var.daily.$end.tar .
  irm $var.daily.$end.tar
done
echo "DONE!"
