#!/bin/bash 

set -x

if [ -z $LSPROCESSING_HOME ]
then
    printf "%b" "Error! Exported shell variable LSPROCESSING_HOME must be set to\n" >&2
    printf "%b" "base directory for headless macros and SLURM scripts.\n" >&2
    exit 1
fi

#SBATCH -J bead_registration                # To give the job a name (move to command line)
#SBATCH -N 1                                # Number of compute nodes being requested (-nodes)
#SBATCH -n 16                               # Number of CPUs in each compute node (–ntasks-per-node)
#SBATCH -t 0-2:00                           # Runtime in D-HH:mm
#SBATCH -p general,serial_requeue           # Partition to submit to (other option: serial_requeue)
#SBATCH --mem=100000                        # Memory per node in MB (see also --mem-per-cpu) 
#SBATCH -o bead_registration_pid%j.out      # Log file of run summary Can be specified in shell
#SBATCH -e bead_registration_pid%j.err      #

# Important note: the number of cores request from SLURM must match the number of
#   parallel threads specified inside the macro (currently 16)

#module load legacy
#module load centos6/fiji-1.47

# set this bash variable if not already set by module load
FIJI_EXEC_DIR=/n/chevrier_lab/apps/fiji-1.49j

# grab headless macro location
##SLURM_EXEC_DIR=$( cd "$( dirname "$0" )" && pwd )
MACRO_PATH="$LSPROCESSING_HOME/headless"

# macro to be used (modified version in lab folder)
MACRO_NAME="bead_registration.headless.ijm"


# check to ensure filepath and outputdir arguments
if (( $# != 6 ))
then
    printf "%b" "Error. Wrong number of arguments.\n" >&2
    printf "%b" "Usage: $0 numChan chan1Dir chan2Dir angleRange xyResolution zResolution\n" >&2
    printf "%b" "\n" >&2
    printf "%b" "          If only one channel, use 'not_used' for chan2Dir\n" >&2
fi

# parameter string to macro will be "1|/n/regal/rc_admin/bfreeman/chevrier/green|not_used|1-6|0.730|2.000"
MACRO_PARAM="$1|$2|$3|$4|$5|$6"


# load headless frame image buffer
export DISPLAY=:1                                          # to avoid using display (GUI)
Xvfb $DISPLAY -auth /dev/null &                            # headless (no display) GUI

# load the fiji paths into java
#JAVA_OPTS="-Djava.library.path=$FIJI_HOME"    now done in fiji bash script
#(
#LD_LIBRARY_PATH=$FIJI_HOME:$LD_LIBRARY_PATH   now done in fiji bash script
# export FIJI_HOME=$FIJI_EXEC_DIR
# export JAVA_OPTS="-Djava.library.path=$FIJI_HOME"
# export PATH=$FIJI_HOME:$PATH
# export LD_LIBRARY_PATH=$FIJI_HOME:$LD_LIBRARY_PATH

$FIJI_EXEC_DIR/fiji --memory=100000m -macro $MACRO_PATH/$MACRO_NAME $MACRO_PARAM

#wait
#)

