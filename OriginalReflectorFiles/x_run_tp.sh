#!/bin/bash

# ./x_run_tp.sh $1 $2
# $1 gives type of mPMT (NP1, NP2, 3inch, 8inch, 20inch)
# $2 is either refl or norefl

clear

echo "Running WCSim simulations for $1 with $2"

filename=x_mPMT_tp.mac

sed -e '7d' $filename > $filename.tmp && mv $filename.tmp $filename
#to do: account for no reflector
sed -e '7 i /control/execute mPMT_'$1'_'$2'.mac' $filename > $filename.tmp && mv $filename.tmp $filename

for theta in {0..20..10}
do
  for phi in {0..0..1}
  do
    echo "theta=$theta phi=$phi"
    
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
    
    sed -e '25d' $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '25d' $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '25d' $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '25d' $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '25d' $filename > $filename.tmp && mv $filename.tmp $filename
    
    sed -e '25 i /gps/pos/centre '$CEN1' '$CEN2' '$CEN3' m' $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '26 i /gps/pos/rot1 '$ROT11' '$ROT12' '$ROT13 $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '27 i /gps/pos/rot2 '$ROT21' '$ROT22' '$ROT23 $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '28 i /gps/direction '$DIR1' '$DIR2' '$DIR3 $filename > $filename.tmp && mv $filename.tmp $filename
    sed -e '29 i /WCSimIO/RootFile x_mPMT_'$1'_'$2'_'$theta'_'$phi'.root' $filename > $filename.tmp && mv $filename.tmp $filename
    
    WCSim $filename
  done
done


