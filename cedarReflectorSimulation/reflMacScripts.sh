#!/bin/bash

# ./reflMacScripts $1 $2 $3
# $1 is theta
# $2 is phi
# $3 is run number from scheduler

dirname=x_mPMT_reflector_${1}_${2}

filename=x_mPMT_tp.mac

FILEROOT=${dirname}/x_mPMT_refl_${1}_${2}_run_${3}
RUN_FILE=${FILEROOT}.mac
cp $filename ${RUN_FILE}

theta=$1
phi=$2

pi=`echo "4*a(1)" | bc -l`
theta_r=`echo "$theta*($pi/180)" | bc -l`
phi_r=`echo "$phi*($pi/180)" | bc -l`
CEN1=`echo "-5+c($phi_r)*c($theta_r)" | bc -l`
CEN2=`echo "c($phi_r)*s($theta_r)" | bc -l`
CEN3=`echo "s($phi_r)" | bc -l`
ROT11=`echo "s($phi_r)*c($theta_r)" | bc -l`
ROT12=`echo "s($phi_r)*s($theta_r)" | bc -l`
ROT13=`echo "-c($phi_r)" | bc -l`
ROT21=`echo "-s($theta_r)/c($theta_r)" | bc -l`
ROT22=1
ROT23=0
DIR1=`echo "-c($phi_r)*c($theta_r)" | bc -l`
DIR2=`echo "-c($phi_r)*s($theta_r)" | bc -l`
DIR3=`echo "-s($phi_r)" | bc -l`
		        
sed -i '25d' ${RUN_FILE}
sed -i '25d' ${RUN_FILE}
sed -i '25d' ${RUN_FILE}
sed -i '25d' ${RUN_FILE}
sed -i '25d' ${RUN_FILE}

sed -i '25 i /gps/pos/centre '$CEN1' '$CEN2' '$CEN3' m' ${RUN_FILE}
sed -i '26 i /gps/pos/rot1 '$ROT11' '$ROT12' '$ROT13 ${RUN_FILE}
sed -i '27 i /gps/pos/rot2 '$ROT21' '$ROT22' '$ROT23 ${RUN_FILE}
sed -i '28 i /gps/direction '$DIR1' '$DIR2' '$DIR3 ${RUN_FILE}
sed -i '29 i /WCSimIO/RootFile '$FILEROOT'.root' ${RUN_FILE}


/project/rpp-tanaka-ab/sarvan13/WCSim/bin/Linux-g++/WCSim ${RUN_FILE} &> logs/${FILEROOT}.log


