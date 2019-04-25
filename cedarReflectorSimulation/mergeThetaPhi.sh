#!/bin/bash

for theta in {-80..80..10}
do
	for phi in {-80..80..10}
	do (
		fileroot="x_mPMT_reflector_"${theta}"_"${phi}"/x_mPMT_refl_"${theta}"_"${phi}"_run_"
		hadd -k "rootFiles/x_mPMT_refl_"${theta}"_"${phi}"_flat.root" ${fileroot}?_flat.root
		hadd -k "rootFiles/x_mPMT_refl_"${theta}"_"${phi}".root" ${fileroot}?.root
		)
	done
done

