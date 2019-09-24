#!/bin/bash

dir1="T15Y5_tarxfer"
dir="ave-Temp-1.5-Year2-Done4-19"

mkdir $dir1

echo $dir
tar -cvf $dir1/month1.tar $dir/*monthly.01.bin
tar -cvf $dir1/month2.tar $dir/*monthly.02.bin
tar -cvf $dir1/month3.tar $dir/*monthly.03.bin
tar -cvf $dir1/month4.tar $dir/*monthly.04.bin
tar -cvf $dir1/month5.tar $dir/*monthly.05.bin
tar -cvf $dir1/month6.tar $dir/*monthly.06.bin
tar -cvf $dir1/month7.tar $dir/*monthly.07.bin
tar -cvf $dir1/month8.tar $dir/*monthly.08.bin
tar -cvf $dir1/month9.tar $dir/*monthly.09.bin
tar -cvf $dir1/month10.tar $dir/*monthly.10.bin
tar -cvf $dir1/month11.tar $dir/*monthly.11.bin
tar -cvf $dir1/month12.tar $dir/*monthly.12.bin
tar -cvf $dir1/yearly.tar $dir/*yearly.bin
tar -cvf $dir1/daily1.tar $dir/*daily.001.bin
tar -cvf $dir1/daily365.tar $dir/*daily.365.bin

echo "Tars created... moving to avra"
icd /iplant/home/lecondon
iput -vrP $dir1

echo " Extracting tars"
icd $dir1
ibun -x month1.tar .
ibun -x month2.tar .
ibun -x month3.tar .
ibun -x month4.tar .
ibun -x month5.tar .
ibun -x month6.tar .
ibun -x month7.tar .
ibun -x month8.tar .
ibun -x month9.tar .
ibun -x month10.tar .
ibun -x month11.tar .
ibun -x month12.tar .
ibun -x yearly.tar .
ibun -x daily1.tar .
ibun -x daily365.tar .

echo "ibun done... moving to sahred"
imv -v $dir /iplant/home/shared/avra/CONUS_1.0/Simulations/1.5Deg_Warming/Processed_Outputs/Year5

echo "clean up time"
icd ../
irm -rf $dir1

echo "DONE!"
