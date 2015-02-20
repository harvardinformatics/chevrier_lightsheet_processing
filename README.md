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
    
where params = 
    
        numChannels numAngles pathToFile outputDir
        
e.g. 

        sbatch $LSPROCESSING_HOME/slurm/Z1_CZI_to_TIF_for_Timelapse_and_Multiview.headless.slurm \
            1 6 \
            /n/regal/bfreeman/11-14_-_1DPI_LSide_5xObj_wbeads_glycerol.czi \
            /n/regal/bfreeman/
        
*Bead registration*

        sbatch $LSPROCESSING_HOME/slurm/bead_registration.headless.slurm params
    
where params = 
    
        numChan chan1Dir chan2Dir angleRange xyResolution zResolution
    
if only 1 channel, use 'not_used' for chan2Dir
    
e.g.

        sbatch $LSPROCESSING_HOME/slurm/bead_registration.headless.slurm \
            1 /n/regal/bfreeman/chevrier/green not_used 1-6 0.730 2.000

*Multi-view fusion*

        sbatch $LSPROCESSING_HOME/slurm/image_fusion.headless.slurm params

where params = 
    
        chan1Dir angleRange
        
only 1 channel is assumed

e.g.

        sbatch $LSPROCESSING_HOME/slurm/image_fusion.headless.slurm \
            /n/regal/bfreeman/chevrier/green 1-6 

## Considerations


## To-do
- current SLURM scripts use 16 cores, 2 hrs, and serial_requeue by default. Macros match the
    16 cores used. This is hardcoded and will be removed.
- Dual/multi-channel stuff is not really wired in.
- App location is hard-coded into 

### Contact
Any questions, please contact Bob Freeman at robert_freeman [at] harvard.edu

