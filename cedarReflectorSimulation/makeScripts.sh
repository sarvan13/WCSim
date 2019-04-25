#!/bin/bash


echo "Creating Cluster Scripts ..."

for theta in {-80..80..10}
do
  for phi in {-80..80..10}
  do
  (
  echo 'Making Script for '${theta}'_'${phi}''

    FILEROOT=x_mPMT_reflector_${theta}_${phi}

    mkdir ${FILEROOT}
    mkdir logs/${FILEROOT}

    CSCRIPT=clusterScripts/${FILEROOT}.sh
    touch ${CSCRIPT}
    echo '#!/bin/bash' >  ${CSCRIPT}
    echo '#SBATCH --job-name='${FILEROOT}'' >> ${CSCRIPT}
    echo '#SBATCH --account=rpp-tanaka-ab' >> ${CSCRIPT}
    echo '#SBATCH --time 10:00:00' >> ${CSCRIPT}
    echo '#SBATCH --mem=2G' >> ${CSCRIPT}
    echo '#SBATCH --output=/project/rpp-tanaka-ab/sarvan13/WCSim/ReflectorSimulation/logs/'${FILEROOT}'/%x-%a.out' >> ${CSCRIPT}
    echo '#SBATCH --error=/project/rpp-tanaka-ab/sarvan13/WCSim/ReflectorSimulation/logs/'${FILEROOT}'/%x-%a.out' >> ${CSCRIPT}
    echo '#SBATCH --array=0-9' >> ${CSCRIPT}
    echo >> ${CSCRIPT}
    echo 'cd /project/rpp-tanaka-ab/sarvan13/WCSim/ReflectorSimulation' >> ${CSCRIPT}
    echo './reflMacScripts.sh '${theta}' '${phi}' '\${SLURM_ARRAY_TASK_ID}'' >> ${CSCRIPT}

    sbatch ${CSCRIPT}
    sleep 2
  )
  done
done

