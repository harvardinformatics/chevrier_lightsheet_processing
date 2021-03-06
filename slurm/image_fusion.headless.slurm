#!/bin/bash 

#SBATCH -J image_fusion                # To give the job a name (move to command line)
#SBATCH -N 1                                # Number of compute nodes being requested (-nodes)
#SBATCH -n 16                               # Number of CPUs in each compute node (–ntasks-per-node)
#SBATCH -t 0-1:00                           # Runtime in D-HH:mm
#SBATCH -p general,serial_requeue           # Partition to submit to (other option: serial_requeue)
#SBATCH --mem=30000                        # Memory per node in MB (see also --mem-per-cpu) 
#SBATCH -o image_fusion_pid%j.out      # Log file of run summary Can be specified in shell
#SBATCH -e image_fusion_pid%j.err      #
#SBATCH --mail-type=ALL                 # send me email on all SLURM actions

# Important note: the number of cores request from SLURM must match the number of
#   parallel threads specified inside the macro (currently 16)

#module load legacy
#module load centos6/fiji-1.47

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

# set this bash variable if not already set by module load
FIJI_EXEC_DIR=/n/chevrier_lab/apps/fiji-1.49j

# specify macro that is not built-in 
##SLURM_EXEC_DIR=$( cd "$( dirname "$0" )" && pwd )
MACRO_PATH="$LSPROCESSING_HOME/headless"

# macro to be used (modified version in lab folder)
MACRO_NAME="image_fusion.headless.ijm"

# check to ensure filepath and outputdir arguments
if (( $# != 2 ))
then
    printf "%b" "Error. Wrong number of arguments.\n" >&2
    printf "%b" "Usage: $0 chan1Dir angleRange\n" >&2
fi

# string usage: numChan|chan1Path|angleRange
#  e.g. "1|/n/regal/rc_admin/bfreeman/chevrier/green|1-6"
MACRO_PARAM="1|$1|$2"

# load headless frame image buffer
if [[ ! $MACRO_DEBUG ]]
then
    export DISPLAY=:1                                          # to avoid using display (GUI)
    Xvfb $DISPLAY -auth /dev/null &                            # headless (no display) GUI
fi

# NOTE: The following are not needed if the custom shell script in the Fiji install
#  dir is used, or the Fiji 1.49j lmod module is loaded
#
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

