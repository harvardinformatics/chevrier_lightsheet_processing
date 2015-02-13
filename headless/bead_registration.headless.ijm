// Created by Bob Freeman, PhD
//      16-Jan-2015

// PURPOSE:
//
//

// ASSUMPTIONS:

// CHANGES:
// 2/5/14: changed macro name

// TO FIX:
// 2/5/14: variable outputDir


//debug = 1;

mdebug = 0;

if (mdebug) { print("Before setting threads"); }
run("Memory & Threads...", "parallel=16");
if (mdebug) { print("After setting threads"); }

macro "Bead-based registration" { 
    print ("Bead-based registration macro!");
    print (" ");
    
    if (mdebug) { print("Entering macro statement"); }

    // get user parameters 
    if (! mdebug) {
        parameter_string = getArgument();
    } else {
        parameter_string = "1|/n/regal/rc_admin/bfreeman/chevrier/green|not_used|1-6|0.730|2.000";
    }
    
    // "numChan|chan1Path|chan2Path"
    args = split(parameter_string, "|");
    numChan = parseInt(args[0]);
    chan1Path = args[1];
    chan2Path = args[2];
    angleRange = args[3];
    xyResolution = parseFloat(args[4]);
    zResolution = parseFloat(args[5);
    
    // debug!!
    if (1) {
        print ("Params...");
        print ("chan1Path: " + chan1Path);
        print ("chan2Path: " + chan2Path);
        print ("angleRange: " + angleRange);
        print ("xyResolution: " + xyResolution);
        print ("zResolution: " + zResolution);
    }

    
    // Create markers for elapsed time.
    if (mdebug) { print ("Creating time markers"); }
    absoluteStart = getTime();

    if (mdebug) { print ("Starting bead registration"); }
	setBatchMode(true);
    if (numChan == 1) {
    
        print ("Performing single-channel bead-based registration...");
        run("Bead-based registration", "select_type_of_registration=Single-channel select_type_of_detection=Difference-of-Gaussian spim_data_directory=" + chan1Path + " pattern_of_spim=spim_TL{ttt}_Angle{a}.tif timepoints_to_process=1 angles_to_process=" + angleRange + " bead_brightness=Strong subpixel_localization=[3-dimensional quadratic fit (all detections)] specify_calibration_manually xy_resolution=" + xyResolution + " z_resolution=" + zResolution + " transformation_model=Affine select_reference=[Manually (interactive)] imglib_container=[Cell container (images larger ~2048x2048x450 px)]");
    } else if (numChan == 2) {
    
        print ("Performing multi-channel bead-based registration...");
        if (0) {
            run("Bead-based registration", "select_type_of_registration=[Multi-channel (same beads visible in different channels)] select_type_of_detection=Difference-of-Gaussian spim_data_directory=/n/regal/rc_admin/bfreeman/chevrier pattern_of_spim=spim_TL{t}_Channel{c}_Angle{a}.lsm timepoints_to_process=1 channels_containing_beads=[0, 1] angles=1-6 xy_resolution=0.730 z_resolution=2.000 transformation_model=Affine select_reference=[Manually (interactive)] imglib_container=[Cell container (images larger ~2048x2048x450 px)] bead_brightness_channel_0=Strong bead_brightness_channel_1=Strong");
        } else {
            print ("NOTE!! Multi-channel bead-based registration not functional at this time!");
        }
    }

    totalTime = (getTime() - absoluteStart) / (1000 * 60);
    print ("ALL DONE! It took " + d2s(totalTime,0) + " minutes.");

    // Save the log file.
    selectWindow("Log");
    thisFile = chan1Path + File.separator + "bead-based_registration.log";
    saveAs("text", thisFile);	

    run("Quit");

}
run("Quit");
