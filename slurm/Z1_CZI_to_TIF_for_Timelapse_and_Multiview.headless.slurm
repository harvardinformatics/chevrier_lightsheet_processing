#!/bin/bash

if [[ $MACRO_DEBUG ]]
then
    set -x                                              # show all steps
fi

if [ -z $LSPROCESSING_HOME ]
then
    printf "%b" "Error! Exported shell variable LSPROCESSING_HOME must be set to\n" >&2
    printf "%b" "base directory for headless macros and SLURM scripts.\n" >&2
    exit 1
fi

#SBATCH -J cz12tif_conversion        # To give the job a name (move to command line)
#SBATCH -N 1                        # Number of compute nodes being requested (-nodes)
#SBATCH -n 16                       # Number of CPUs in each compute node (–ntasks-per-node)
#SBATCH -t 0-1:00                   # Runtime in D-HH:mm
#SBATCH -p serial_requeue           # Partition to submit to (other option: serial_requeue)
#SBATCH --mem=30000                # Memory per node in MB (see also --mem-per-cpu) 
#SBATCH -o cz12tif_conversion_pid%j.out      # Log file of run summary Can be specified in shell
#SBATCH -e cz12tif_conversion_pid%j.err      #

# Important note: the number of cores request from SLURM must match the number of
#   parallel threads specified inside the macro (currently 16)

#module load legacy
#module load centos6/fiji-1.47

# set this bash variable if not already set by module load
FIJI_EXEC_DIR=/n/chevrier_lab/apps/fiji-1.49j

##SLURM_EXEC_DIR=$( cd "$( dirname "$0" )" && pwd )
MACRO_PATH="$LSPROCESSING_HOME/headless"

# macro to be used (modified version in lab folder)
MACRO_NAME="Z1_CZI_to_TIF_for_Timelapse_and_Multiview.headless.ijm"

# check to ensure filepath and outputdir arguments
if (( $# != 2 ))
then
    printf "%b" "Error. Wrong number of arguments.\n" >&2
    printf "%b" "Usage: $0 numChan numAngles czi_filepath outputdir/\n" >&2
fi

# string usage: numChan|numAngle|numTime|binX|binY|binZ|chanName1|chanName2|chanName3|chanName4|filePath|outputDir
NUM_CHAN=$1
NUM_ANGLES=$2
FILE_PATH=$3
OUTPUT_DIR=$4                       # must end with '/'
# X|Y|Z etc
MACRO_PARAM="$NUM_CHAN|$NUM_ANGLES|1|1|1|1|green|red|blank|blank|$FILE_PATH|$OUTPUT_DIR"


# load headless frame image buffer
if [[ ! $MACRO_DEBUG ]]
then
    export DISPLAY=:1                                          # to avoid using display (GUI)
    Xvfb $DISPLAY -auth /dev/null &                            # headless (no display) GUI
fi

# load the fiji paths into java
#JAVA_OPTS="-Djava.library.path=$FIJI_HOME"    now done in fiji bash script
#(
#LD_LIBRARY_PATH=$FIJI_HOME:$LD_LIBRARY_PATH   now done in fiji bash script
# export FIJI_HOME=$FIJI_EXEC_DIR
# export JAVA_OPTS="-Djava.library.path=$FIJI_HOME"
# export PATH=$FIJI_HOME:$PATH
# export LD_LIBRARY_PATH=$FIJI_HOME:$LD_LIBRARY_PATH

$FIJI_EXEC_DIR/fiji --memory=30000m -macro $MACRO_PATH/$MACRO_NAME $MACRO_PARAM

#wait
#)

