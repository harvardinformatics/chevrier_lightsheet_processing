// Created by J Farrell 2014/04/08
// Modified by D Richardson 2014/11/07

// Make a dialog to find out how many channels, timepoints, and angles to anticipate.
macro "Z1 CZI to TIF for Timelapse and Multiview data" {
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

// Inside of the output directory, make a directory for each channel.
	for (currChan=1; currChan <= numChan; currChan++) {
		chanDir=outputDir+File.separator+chanName[currChan];
		blah=File.makeDirectory(chanDir);
	}

// Create markers for elapsed time.
    openElapsed=0;
    processElapsed=0;
    timesDone=0;
    timesRemain=0;
    filesRemain=numAngle*numTime;
    filesDone=0;
    absoluteStart=getTime();



// Loop through every angle and timepoint.
    for (Angle=1; Angle <= numAngle; Angle++) {
	    for (Time=1; Time <= numTime; Time++) {
		    print ("Opening Angle "+ Angle + " Timepoint " + Time);
		    startedAt = getTime();
		    setBatchMode(true);
		    // Open the file
		    run("Bio-Formats Importer", "open=" + filePath + " color_mode=Default specify_range view=Hyperstack stack_order=XYCZT series_" + Angle + " c_begin_" + Angle + "=1 c_end_" + Angle + "=2 c_step_" + Angle + "=1 z_begin_" + Angle + "=1 z_end_" + Angle + "=187 z_step_" + Angle + "=1 t_begin_" + Angle + "=" + Time + " t_end_" + Angle + "=" + Time + " t_step_" + Angle + "=1");
		    print ("Opened Angle "+ Angle + " Timepoint " + Time);
		    print ("Downsampling");
		    run("Split Channels");
		    // Downsample and save
            for (currChan = numChan; currChan > 0; currChan--) {
                run("Bin...", "x=" + binX + " y=" + binY + " z=" + binZ + " bin=Average");
                filename=outputDir + "\\" + chanName[currChan]+ "\\" + "spim_TL"+IJ.pad(Time,3)+"_Angle"+d2s(Angle,0)+".tif";
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

    totalTime=(getTime()-absoluteStart)/(1000*60);
    print ("ALL DONE! It took "+d2s(totalTime,0)+" minutes.");

    // Save the log file.
    selectWindow("Log");
    thisFile=outputDir+"CZI_to_TIF.log";
    saveAs("text",thisFile);	
}