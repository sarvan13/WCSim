#!/bin/bash

# ./x_run_tp.sh $1 $2 $3 $4
# $1 is reflector angle in degrees 
# $2 is reflector height in mm
# $3 is the z offset of the reflector from the edge of the PMT in mm
# $4 is the x offset of the reflector from the edge of the PMT in mm


clear

echo "Running WCSim simulations for '$1' degree reflector"

filename=x_mPMT_tp.mac
reflFile=mPMT_NP2_refl.mac

sed -i '7d' $filename
#to do: account for no reflector
sed -i '7i /control/execute mPMT_NP2_refl.mac' $filename

sed -i '16d' $reflFile
sed -i '16d' $reflFile
sed -i '16d' $reflFile
sed -i '16d' $reflFile

sed -i '16 i /WCSim/mPMT/reflectorAngleID '$1' mm' $reflFile
sed -i '16 i /WCSim/mPMT/reflectorXoffsetID '$4' mm' $reflFile
sed -i '16 i /WCSim/mPMT/reflectorZoffsetID '$3' mm' $reflFile
sed -i '16 i /WCSim/mPMT/reflectorHeightID '$2' deg' $reflFile

WCSimEXE=/neut/data21/gill/sarvanWCSim/WCSim/geant4_workdir/bin/Linux-g++/WCSim

for theta in {-80..80..10}
do
  for phi in {-80..80..10}
  do
(
    echo "theta=$theta phi=$phi"

    FILEROOT=x_mPMT_NP2_refl_${theta}_${phi}
    RUN_FILE=${FILEROOT}.mac
    cp $filename ${RUN_FILE}
    
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
    
    touch clusterScripts/${FILEROOT}.pbs
    echo '#!/bin/bash' >  clusterScripts/${FILEROOT}.pbs
    echo >> clusterScripts/${FILEROOT}.pbs
    echo '#PBS -N '${FILEROOT}'' >> clusterScripts/${FILEROOT}.pbs
    echo '#PBS -j oe' >> clusterScripts/${FILEROOT}.pbs
    echo '#PBS -l walltime=12:00:00,mem=2000mb,vmem=2000mb' >> clusterScripts/${FILEROOT}.pbs
    echo >> clusterScripts/${FILEROOT}.pbs
    echo 'source ~/.bashrc' >> clusterScripts/${FILEROOT}.pbs
    echo 'cd /neut/data21/gill/sarvanWCSim/WCSim/ReflectorSimulation' >> clusterScripts/${FILEROOT}.pbs
    echo ''${WCSimEXE}' '${RUN_FILE}' &> logs/'${FILEROOT}'.log' >> clusterScripts/${FILEROOT}.pbs

    qsub clusterScripts/${FILEROOT}.pbs
  )
  done
done
