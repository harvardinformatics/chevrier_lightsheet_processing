# chevrier_lightsheet_processing
ImageJ macros for Lightsheet microscope processing for Nicolas Chevrier

## Purpose
A set of ImageJ/Fiji macros to run headless on HPC under SLURM

## Usage
Each of these headless macros should be invoked using the appropriate SLURM script:

Before running any of these, you must set LSPROCESSING_HOME to the base folder. E.g.
    export LSPROCESSING_HOME=/home/bfreeman/git/chevrier_lightsheet_processing
    
*CZI to TIF conversion*

    sbatch $LSPROCESSING_HOME/slurm/Z1_CZI_to_TIF_for_Timelapse_and_Multiview.headless.slurm params

*Bead registration*

    sbatch $LSPROCESSING_HOME/slurm/bead_registration.headless.slurm params

*Multi-view fusion*

    sbatch $LSPROCESSING_HOME/slurm/image_fusion.headless.slurm params

## Considerations


## To-do


### Contact
Any questions, please contact Bob Freeman at robert_freeman [at] harvard.edu

