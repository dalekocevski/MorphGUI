# MorphGUI README

MorphGUI is a perl-based visual classification GUI developed as part of the CANDELS survey.

# Installation:
MorphGUI is a fairly simple perl script, but you'll need a few things to get it working. In addition to ds9, you'll need the Tk module for Perl and the program XPA. The XPA binaries are included in various things like the scisoft distribution and ciao, so you may already have them installed. To check, type 'which xpaset'. If you don't, you can download the binaries for Linux and MacOS from the ds9 website:

http://hea-www.harvard.edu/RD/ds9/

Make sure to place the XPA binaries somewhere in your path (anywhere will work, as long as they are visible and executable).  As for the Tk module, you can test whether this is already installed on your system with the command:

    perl -e "use Tk"

If you get the response 'Can't locate Tk.pm', then you'll need to install it. You can grab the source code here:

http://search.cpan.org/~srezic/Tk-804.030/

To compile it, follow these steps:

    tar xvf Tk-804.029.tar
    cd Tk-804.029
    perl Makefile.PL
    more Makefile | sed "/PNG/d" > Makefile2 mv Makefile2 Makefile
    make
    make test make install
  
You'll need root access for that last step, so you may need to preface that command with 'sudo'. Make sure you have X11 running when you compile the code; the 'make test' step will bring up some example GUIs to make sure everything is working.

Running the Code:
Once perl/Tk is installed, simply unpack the GUI tarball and run the commands:

    ds9 -title MorphGUI & MorphGUI.pl examples.lst

Notice you'll need to launch ds9 first. If you are using the MacOS version of DS9 instead of the X11 version, you'll need to specify the full path to the ds9 binary in order to change the window title. Here's an example:

    /Applications/SAOImage\ DS9.app/Contents/MacOS/ds9 -title MorphGUI
    
A few example fits thumbnails are included in this repository.  These should get displayed on the resized ds9 windows. When you are ready to start classifying your own galaxies, simply replace examples.lst with the source list for your subsample. For example:

    ds9 -title MorphGUI & 
    MorphGUI.pl ERS5.cat
    
The GUI lists the current source (and how many you have remaining) in an info panel at the bottom of the GUI window. This info panel will be red if the galaxy in question has not yet been classified. If you move back (or jump) to source that you have already classified, the panel will turn green. If you click on the "Jump To" button, you'll get a list of all the galaxies in your subsample and whether they've been classified. Remember, you must click the "Submit & Next" button in order for your classification to be saved into memory.

Thumbnail Location:
The code assumes the fits thumbnails are located in the directory ./thumbnails/ although this can be changed via a command line option (see below). The thumbnails should include the v, z, j, and h "postage stamp" images, as well as the segmentation map cutouts.

Saving/Loading Your Results:
The GUI can save your current results so you don't have to finish your classifications in one sitting. To do this, use File->Save from the pulldown menu. To load your previous classifications, likewise use File->Open.

Command Line Options:
There are a few command line options for the GUI. The calling sequence is:

    MorphGUI.pl source_list.cat [-o previous_classifications.dat] [-p path_to_thumbnails] [-n] [-s] 

The options are:
    -o previous_classifications.dat : Load your previously saved results upon startup
    -p path_to_thumbnails_dir : Specify path to fits thumbnail directory (default is ./thumbnails/) -n : Do not reset ds9         when advancing to next source
    -s : Run GUI in silent mode (i.e. no popup notifications)
    
Controlling DS9 from the GUI:
Although the GUI resizes the DS9 window, all the usual DS9 features and controls are accessible from the DS9 file menu. If you don't want to resort to using the file menu, I've placed a few buttons on the main GUI window that will control DS9. These buttons are fairly self explanatory (i.e. 'Match Stretch' will match your current stretch over the four images, 'Invert Colormap' will invert white/black and 'Reset Frames' sets the images back to their default settings). The button 'Show Segmap' will cause DS9 to show an outline of the sextractor segmentation map for the galaxy displayed. This works most of the time, but it has it's limitations.

A Couple of Examples:

  1.) Say you want to classify galaxies in the list ERS1.cat and you wish to load your previous results:

    MorphGUI.pl ERS1.cat -o old_results.dat
    
  2.) If you want to classify galaxies in the list ERS5.cat and you wish to load your previous results and specify a thumbnail directory:

    MorphGUI.pl ERS5.cat -o old_results.dat -p ./thumbnails/ERS/
    
    
Dale Kocevski - 9/28/15
