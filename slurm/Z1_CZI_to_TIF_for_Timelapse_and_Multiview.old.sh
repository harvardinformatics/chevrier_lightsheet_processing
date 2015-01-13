#!/bin/bash 

#SBATCH -J job_name			# To give the job a name (move to command line)
#SBATCH -N 1				# Number of compute nodes being requested (-nodes)
#SBATCH -n 16  				# Number of CPUs in each compute node (–ntasks-per-node)
#SBATCH -t 0-12:00 			# Runtime in D-HH:mm
#SBATCH -p general  		# Partition to submit to (other option: serial_requeue)
#SBATCH --mem=100000 		# Memory per node in MB (see also --mem-per-cpu) 
#SBATCH -o job_name.out		# Log file of run summary Can be specified in shell
#SBATCH -e job_name.err		#

# Important note: the number of cores must match the number of parallel threads specified inside the macro (currently 16)

module load legacy
module load centos6/fiji-1.47

FIJI_HOME=/n/sw/centos6/fiji-1.47
MACRO_PATH="/n/chevrier_lab/apps/fiji"							# specify macro that is not built-in /n/sw/centos6/fiji-1.47/plugins/Z1_CZI_to_TIF_for_Timelapse_and_Multiview.ijm
MACRO_NAME="Z1_CZI_to_TIF_for_Timelapse_and_Multiview_NC.ijm"	# macro to be used (modified version in lab folder)


# string usage: numChan|numAngle|numTime|binX|binY|binZ|chanName1|chanName2|chanName3|chanName4|filePath|outputDir
FILE_PATH=/n/chevrier_lab/users/donaldbrooks/Data/CLARITY/Time_Course_with_DQ-OVA_2/11-14_1DPI_Right_Side_5x_obj_with_beads_in_glycerol.czi
OUTPUT_DIR=/n/chevrier_lab/users/donaldbrooks/Data/CLARITY/
MACRO_PARAM="1|6|1|1|1|1|green|red|blank|blank|$FILE_PATH|$OUTPUT_DIR"				# X|Y|Z (how does the macro process the concatenated parameters)


# load headless frame image buffer
export DISPLAY=:1												# to avoid using display (GUI)
Xvfb $DISPLAY -auth /dev/null &									# headless (no display) GUI

# load the fiji paths into java
JAVA_OPTS="-Djava.library.path=$FIJI_HOME"						
(
LD_LIBRARY_PATH=$FIJI_HOME:$LD_LIBRARY_PATH
fiji -macro $MACRO_PATH/$MACRO_NAME $MACRO_PARAM
wait
)

# srun --pty --x11=first --mem=100000 -n 16 -N 1 -p general -t 0-1:0 /bin/bash
# By default, ImageJ/Fiji will grab *all* cores on the node. 
# So you need to tame it by including in your macro the command to limit the # of threads to the # of cores requested from SLURM 
# (e.g. -n X -N 1  == X cores on one node)
# run("Memory & Threads...", "parallel=XX");

## HOW TO RUN FIJI GUI ON THE CLUSTER WITH NOMACHINE
# follow instructions on RC websites (see link below), to setup nomachine software on your machine
# https://rc.fas.harvard.edu/resources/access-and-login/#Consider_an_NX_remote_desktop_for_graphical_applications_like_Matlab_and_RStudio
# connect to VPN (required for nomachine to work)
# start nomachine software (display resizing can be done once the session is loaded, using the tab key to access hidden buttons)
# login and start a new GNOME virtual desktop
# start Applications -> System Tools -> Terminal
# in the shell prompt, add the following command to load an interactive session on the cluster requesting 200Gb of memory for 2 h
# $ srun --pty --x11=first --mem=200000 -n 16 -N 1 -p general -t 0-2:00 /bin/bash
# once the session kicksin, run the following commands to load required modules
# $ module load legacy
# $ module load centos6/fiji-1.47
# type fiji to load the fiji software GUI
# $ fiji
# process files using pre-installed plugins as follows: (1) .czi -> .tif; (2) bead-based registration; (3) multi-view fusion

## From Bob on 11/25
# I've copied the latest version of fiji to /n/chevrier_lab/apps/fiji-1.49j. 
# You can run it by using the following commands, both interactively (the X11/Nomachine GUI) or with the headless  one.
# I do recommend trying the GUI one first, as then you can set your options there, 
# which creates a personal config file in your home directory. 
# 
# To run your local copy of fiji (assuming bash): 
# 
# export IMAGEJ_HOME=/n/chevrier_lab/apps/fiji-1.49j
# export PATH=$IMAGEJ_HOME:$IMAGEJ_HOME/java/linux-amd64/jdk1.6.0_24/jre/bin:$PATH
# export CLASSPATH=IMAGEJ_HOME:$IMAGEJ_HOME/jars:$CLASSPATH
# export LD_LIBRARY_PATH=$IMAGEJ_HOME
# export JAVA_OPTS="-Djava.library.path=$IMAGEJ_HOME"
# 
# fiji