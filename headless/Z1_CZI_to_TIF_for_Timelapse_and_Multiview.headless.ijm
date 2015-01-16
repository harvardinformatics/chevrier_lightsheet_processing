// Created by J Farrell 2014/04/08
// Modified by D Richardson 2014/11/07

// Make a dialog to find out how many channels, timepoints, and angles to anticipate.


//  ENSURE THAT YOU'VE REQUESTED THIS # OF CORES FROM SLURM!!
//     or Bob Freeman will come after you
//

mdebug = 0;

if (mdebug) { print("Before setting threads"); }
run("Memory & Threads...", "parallel=16");
if (mdebug) { print("After setting threads"); }

macro "Z1 CZI to TIF for Timelapse and Multiview data" { 
	if (mdebug) { print("Entering macro statement"); }
    if(0){
        Dialog.create("Parameters of your acquisiton");
        Dialog.addMessage("First, define here the parameters of your acquisition.");
        Dialog.addNumber("Number of channels?",1);
        Dialog.addMessage("How many angles/views are there?");
        Dialog.addNumber("Angles/views?",3);
        Dialog.addMessage("How many timepoints are there?");
        Dialog.addNumber("Timepoints",1);
        Dialog.addMessage("Do you want to bin (downsample)?");
        Dialog.addNumber("Bin in X",1);
        Dialog.addNumber("Bin in Y",1);
        Dialog.addNumber("Bin in Z",1);
        Dialog.show();
        numChan = Dialog.getNumber();
        numAngle = Dialog.getNumber();
        numTime = Dialog.getNumber();
        binX = Dialog.getNumber();
        binY = Dialog.getNumber();
        binZ = Dialog.getNumber();
        chanDefaults = newArray("","green","red","","");

    // Make a dialog to find out the parameters of the channels
        Dialog.create("Parameters of your acquisition");
        Dialog.addMessage("What are the names of your channels?");
        for (currChan=1; currChan <= numChan; currChan++) {
            if (currChan > 4) {
                chanDefaults[currChan]="";
            }
            Dialog.addString("Channel "+currChan+":", chanDefaults[currChan]);
        }
        Dialog.addMessage(" ");
        Dialog.addMessage("After clicking OK, you will be prompted to select\n" +
        "the original .CZI file and an output location for \n" +
        "the files corresponding to each channel.");
        Dialog.show()
        chanName=newArray(numChan+1);
        for (currChan=1; currChan <= numChan; currChan++) {
            chanName[currChan]=Dialog.getString();
            chanName[currChan]=replace(chanName[currChan], " ", "_");
        }

    // Get the path to each file and the output directory.
        filePath=File.openDialog("Original .CZI file");
        outputDir=getDirectory("Choose an output location");
	} else {
		if (mdebug) { print("starting arg parsing"); }
        //numChan
        //numAngle
        //numTime
        //binX
        //binY
        //binZ
        //chanDefaults[0-4]    // channel names, 0-indexed
        //chanName[numChan+1]  // 
        //filePath             // original .CZI file
        //outputDir            // output location for all channels
        //chanDir              // output directory named for each

        // get user parameters 
        parameter_string = getArgument();
        // "1|x|b|some file|c"
        args = split(parameter_string, "|");

        maxnumChan = 4;        // this affects param parsing later!
        numChan = parseInt(args[0]);
        numAngle = parseInt(args[1]);
        numTime = parseInt(args[2]);
        binX = parseInt(args[3]);
        binY = parseInt(args[4]);
        binZ = parseInt(args[5]);
        chanName=newArray("","green","red","","");
        for (index=1; index <=maxnumChan; index++) {
            chanName[index] = replace(args[5+index], " ", "_");
        }
        filePath = args[10];
        outputDir = args[11];

        // eg. numChan|numAngle|numTime|binX|binY|binZ|chanName1|chanName2|chanName3|chanName4|filePath|outputDir
        
        // debug!!
        if (1) {
            print ("Params...");
            print ("numChan: " + numChan);
            print ("numAngle: " + numAngle);
            print ("numTime: " + numTime);
            print ("binX: " + binX);
            print ("binY: " + binY);
            print ("binZ: " + binZ);
            chanName=newArray("","green","red","","");
            for (index=1; index <=maxnumChan; index++) {
                print("channel" + index + ": " + chanName[index]);
            }
            print("filePath: " + filePath);
            print("outputDir: " + outputDir);
        }
	}

// Inside of the output directory, make a directory for each channel.
    if (mdebug) { print ("Creating output directories"); }
	for (currChan = 1; currChan <= numChan; currChan++) {
		chanDir = outputDir + File.separator + chanName[currChan];
		blah = File.makeDirectory(chanDir);
	}

// Create markers for elapsed time.
    if (mdebug) { print ("Creating markers"); }
    openElapsed = 0;
    processElapsed = 0;
    timesDone = 0;
    timesRemain = 0;
    filesRemain = 0;
    filesRemain = numAngle * numTime;
    filesDone = 0;
    absoluteStart = getTime();

// Loop through every angle and timepoint.
    for (Angle=1; Angle <= numAngle; Angle++) {
	    for (Time=1; Time <= numTime; Time++) {
		    print ("Opening Angle "+ Angle + " Timepoint " + Time);
		    startedAt = getTime();
		    setBatchMode(true);
		    // Open the file
		    run("Bio-Formats Importer", "open=" + filePath + " color_mode=Default specify_range view=Hyperstack stack_order=XYCZT series_" + Angle + " c_begin_" + Angle + "=1 c_end_" + Angle + "=2 c_step_" + Angle + "=1 z_begin_" + Angle + "=1 z_end_" + Angle + "=187 z_step_" + Angle + "=1 t_begin_" + Angle + "=" + Time + " t_end_" + Angle + "=" + Time + " t_step_" + Angle + "=1");
		    print ("Opened Angle "+ Angle + " Timepoint " + Time);
		    if (mdebug) { print ("Downsampling"); }
		    run("Split Channels");
		    // Downsample and save
            for (currChan = numChan; currChan > 0; currChan--) {
                run("Bin...", "x=" + binX + " y=" + binY + " z=" + binZ + " bin=Average");
                filename=outputDir + File.separator + chanName[currChan]+ File.separator + "spim_TL"+IJ.pad(Time,3)+"_Angle"+d2s(Angle,0)+".tif";
			    saveAs("Tiff", filename);	
			    close();
            }
            call("java.lang.System.gc");
            setBatchMode(false);
            print ("Downsampled Angle "+ Angle + " Timepoint " + Time+ ": " + binX + " x " + binY + " x " + binZ + " times");
            // Update counters
		    openElapsed += getTime() - startedAt;
		    filesDone += 1;
		    filesRemain -= 1;
		    print ("Files completed = " + filesDone + " Files remaining = " + filesRemain); 
	    }
    }

    totalTime = (getTime() - absoluteStart) / (1000 * 60);
    print ("ALL DONE! It took " + d2s(totalTime,0) + " minutes.");

    // Save the log file.
    selectWindow("Log");
    thisFile = outputDir + "CZI_to_TIF.log";
    saveAs("text", thisFile);	

    run("Quit");

}
run("Quit");



