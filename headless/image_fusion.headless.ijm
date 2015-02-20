// Created by Bob Freeman, PhD
//      5-Feb-2015

// PURPOSE:
//
//

// ASSUMPTIONS:

// CHANGES:

// TO FIX:

// debug = 1;
// $HOME/git/chevrier_lightsheet_processing/headless/image_fusion.headless.ijm

mdebug = 0;

if (mdebug) { print("Before setting threads"); }
run("Memory & Threads...", "parallel=16");
if (mdebug) { print("After setting threads"); }

macro "Multi-view fusion" { 
    print ("Multi-view fusion (headless) macro!");
    print (" ");
    
    if (mdebug) { print("Entering macro statement"); }

    // get user parameters 
    if (! mdebug) {
        parameter_string = getArgument();
    } else {
        parameter_string = "1|/n/regal/rc_admin/bfreeman/chevrier/green|1-6";
    }
    
    // "numChan|chan1Path|angleRange"
    args = split(parameter_string, "|");
    numChan = parseInt(args[0]);
    chan1Path = args[1];
    angleRange = args[2];

    // debug!!
    if (1) {
        print ("Params...");
        print ("numChan: " + numChan);
        print ("chan1Path: " + chan1Path);
        print ("angleRange: " + angleRange);
    }
    
    // Create markers for elapsed time.
    if (mdebug) { print ("Creating time markers"); }
    absoluteStart = getTime();

    // run multi-view fusion for single channel
    if (mdebug) { print ("Starting multi-view fusion plugin"); }
	setBatchMode(true);
    run("Multi-view fusion", "select_channel=Single-channel spim_data_directory=" + chan1Path + " pattern_of_spim=spim_TL{ttt}_Angle{a}.tif timepoints_to_process=1 angles=" + angleRange + " registration=[Individual registration of channel 0] fusion_method=[Fuse into a single image] process_views_in_paralell=All blending downsample_output=1 crop_output_image_offset_x=0 crop_output_image_offset_y=0 crop_output_image_offset_z=0 crop_output_image_size_x=0 crop_output_image_size_y=0 crop_output_image_size_z=0 fused_image_output=[Save 2d-slices, all in one directory]");

    // manage elapsed time
    totalTime = (getTime() - absoluteStart) / (1000 * 60);
    print ("ALL DONE! It took " + d2s(totalTime,0) + " minutes.");

    // Save the log file.
    selectWindow("Log");
    thisFile = chan1Path + File.separator + "multi-view_fusion.log";
    saveAs("text", thisFile);	

    run("Quit");

}
run("Quit");
