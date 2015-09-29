#! /usr/bin/perl
use Tk;
use Tk::widgets qw/JPEG/;
use Tk::LabEntry;
use Tk::LabFrame;

$usage = "\nUsage: $0 source_list [options]\n
Additional parameters:
\t -o previous_classifications.dat (Load your previously saved results upon startup)
\t -p path_to_thumbnails           (Specify path to fits thumbnail directory - default is ./thumbnails/) 
\t -n                              (Do not reset ds9 when advancing to next source)
\t -s                              (Run GUI in silent mode, i.e. no popup notifications)

For additional help, see:  https://github.com/dalekocevski/MorphGUI\n\n";


$path = "./thumbnails/";


my $main = MainWindow->new;
$main->title("CANDELS Morph Classifier");
$main->resizable(0, 0);

my $mf = $main->Frame(-relief => 'groove', -borderwidth => 2);
$mf->pack(-side => 'top', -anchor => 'n', -expand => 1, -fill => 'x');

# Menubar
$file = $mf->Menubutton(-text => 'File', -tearoff => 0,
		-menuitems => [[ 'command' => "Open", -command => \&open_prev, -accelerator => '- Control+O'],
                               [ 'command' => "Save", -command => \&save_curr, -accelerator => '- Control+S'],
			       "-",
			       [ 'command' => "Exit", -command => sub {exit}]
			       ]);
$edit = $mf->Menubutton(-text => 'Tools', -tearoff => 0,
		-menuitems => [[ 'command' => "Show Segmap", -command => \&show_segmap, -accelerator => '- Control+G'],
			       [ 'command' => "Hide Segmap", -command => \&hide_segmap, -accelerator => '- Control+H'],
			       [ 'command' => "Match WCS", -command => \&match_wcs, -accelerator => '- Control+W'],
			       [ 'command' => "Match Stretch", -command => \&match_colorbar, -accelerator => '- Control+T'],
			       [ 'command' => "Invert Colormap", -command => \&invert_colormap, -accelerator => '- Control+I'],
			       [ 'command' => "Reset Frames", -command => \&reset_frames, -accelerator => '- Control+R'],
			       [ 'command' => "Jump To", -command => \&jump_popup, -accelerator => '- Control+J']]);
$help = $mf->Menubutton(-text => 'Help', -tearoff => 0,
			-menuitems => [[ 'command' => "About", -command => \&about],
				       [ 'command' => "Tutorial", -command => \&tutorial]]);

$file->pack(-side => 'left');
$edit->pack(-side => 'left');
$help->pack(-side => 'left');

# Define Shortcuts
$main->bind('<Control-o>', [\&open_file]);
$main->bind('<Control-s>', [\&save_file]);
$main->bind('<Control-g>', [\&show_segmap]);
$main->bind('<Control-h>', [\&hide_segmap]);
$main->bind('<Control-w>', [\&match_wcs]);
$main->bind('<Control-t>', [\&match_colorbar]);
$main->bind('<Control-i>', [\&invert_colormap]);
$main->bind('<Control-r>', [\&reset_frames]);
$main->bind('<Control-j>', [\&jump_popup]);

# Define Filetypes for Save/Open Dialogs
$filetypes = [['Data files', '.dat'], 
	      ['All Files',   '*'],];


# Make Thumbnail Panel I
# $c = $main->Canvas(-width => 42,-height => 80)->pack(-side => "top", -fill => 'both');
$c = $main->LabFrame(-label => "Morphology Class:", -labelside => "acrosstop",-height => 80,-width => 42,-relief => 'flat',-foreground => 'DarkRed')->pack(-side => "top",-fill => 'both');

# Insert Example Thumbnails I
$filler_frame = $c->Frame(-height => 10,-width => 12)->pack(-side => 'left',-fill => 'y');

$image_disk = $main->Photo(-file => "./MorphGUI_files/Disk.128.jpg",-width => 128, -height => 128);
$image_sph = $main->Photo(-file => "./MorphGUI_files/Spheroid.128.jpg",-width => 128, -height => 128);
$image_irr = $main->Photo(-file => "./MorphGUI_files/Irr.128.jpg",-width => 128, -height => 128);
$image_merg = $main->Photo(-file => "./MorphGUI_files/Merger.128.jpg",-width => 128, -height => 128);
$image_int = $main->Photo(-file => "./MorphGUI_files/Int2b.128.jpg",-width => 128, -height => 128);
$image_int2 = $main->Photo(-file => "./MorphGUI_files/Int1b.128.jpg",-width => 128, -height => 128);
# $image_int1b = $main->Photo(-file => "Int1c.128.jpg",-width => 128, -height => 128);
# $image_int2b = $main->Photo(-file => "Int2d.128.jpg",-width => 128, -height => 128);
$image_pair = $main->Photo(-file => "./MorphGUI_files/Pair.128.jpg",-width => 128, -height => 128);
$image_uncl = $main->Photo(-file => "./MorphGUI_files/Unclass.128.jpg",-width => 128, -height => 128);
$image_comp = $main->Photo(-file => "./MorphGUI_files/Compact.128.jpg",-width => 128, -height => 128);
$thumb1 = $c->Label(-image => $image_disk)->pack(-side => 'left',-anchor => 'w');
$thumb2 = $c->Label(-image => $image_sph)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb3 = $c->Label(-image => $image_irr)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb6 = $c->Label(-image => $image_comp)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb7 = $c->Label(-image => $image_uncl)->pack(-side => 'left',-anchor => 'w');

# Make Main Morph Classifications I
$sf = $main->Frame(-relief => 'groove', -borderwidth => 0,-height => 400,-width => 400)->pack(-side => 'top');
@catcb[0] = $sf->Button(-text => "Disk",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3", -command => \&button_disk)->pack(-side => 'left',-anchor => 'n',-padx => 17,-pady => 2);
@catcb[1] = $sf->Button(-text => "Spheroid",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_spheroid)->pack(-side => 'left',-anchor => 'n',-padx => 14,-pady => 2);
@catcb[2] = $sf->Button(-text => "Pec / Irr",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_irr)->pack(-side => 'left',-anchor => 'n',-padx => 16,-pady => 2);
@catcb[3] = $sf->Button(-text => "Point Source",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_compact)->pack(-side => 'left',-anchor => 'n',-padx => 16,-pady => 2);
@catcb[4] = $sf->Button(-text => "Unclassifiable",-width => 12,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_uncl)->pack(-side => 'top',-anchor => 'n',-padx => 10,-pady => 2);



# Make Thumbnail Panel II
# $c2 = $main->Canvas(-width => 42,-height => 80)->pack(-side => "top", -fill => 'both');
$c2 = $main->LabFrame(-label => "Interaction Class:", -labelside => "acrosstop",-height => 80,-width => 42,-relief => 'flat',-foreground => 'DarkRed')->pack(-side => "top",-fill => 'both');

# Insert Example Thumbnails II
$filler_frame = $c2->Frame(-height => 10,-width => 8)->pack(-side => 'left',-fill => 'y');
$thumb4 = $c2->Label(-image => $image_merg)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb5 = $c2->Label(-image => $image_int)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb8 = $c2->Label(-image => $image_int2)->pack(-side => 'left',-anchor => 'w',-padx => 5);
$thumb9 = $c2->Label(-image => $image_pair)->pack(-side => 'left',-anchor => 'w',-padx => 2);
$thumb10 = $c2->Label(-image => $image_sph)->pack(-side => 'left',-anchor => 'w',-padx => 2);

# Make Main Morph Classifications II
$sf2 = $main->Frame(-relief => 'groove', -borderwidth => 0,-height => 400,-width => 400)->pack(-side => 'top');
@catcb[5] = $sf2->Button(-text => "Merger",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_merger)->pack(-side => 'left',-anchor => 'n',-padx => 7,-pady => 2);
@catcb[6] = $sf2->Button(-text => "Interaction\n(within segmap)",-width => 14,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_int1)->pack(-side => 'left',-anchor => 'n',-padx => 5,-pady => 2);
@catcb[7] = $sf2->Button(-text => "Interaction\n(outside segmap)",-width => 15,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_int2)->pack(-side => 'left',-anchor => 'n',-padx => 2,-pady => 2);
@catcb[8] = $sf2->Button(-text => "Non-Interacting\nCompanion",-width => 14,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_pair)->pack(-side => 'left',-anchor => 'n',-padx => 5,-pady => 2);
@catcb[9] = $sf2->Button(-text => "None",-width => 10,-anchor => 'w',-relief => 'raised',-background => "#AAAFC3",-command => \&button_none)->pack(-side => 'left',-anchor => 'n',-padx => 5,-pady => 2);

# Make Info / Progress Frame
$info = "Loading source list...";
$infoframe = $main->Label(-textvariable => \$info, -relief => 'groove', -background => 'IndianRed1')->pack(-side => 'bottom', -fill => 'x');


initialize();


## Make Clump Analysis Window
make_clump_window();



## Make & Populate Flag Frames

# K-correction
$kcorr_frame = $main->LabFrame(-label => "K-correction", -labelside => "acrosstop",-height => 95,-width => 140)->pack(-side => 'left',-fill => 'y');
$cb1 = $kcorr_frame->Checkbutton(-text => "$flags[0][0]",-variable => \$flags[0][1],-width => 16,-anchor => 'w')->place(-x => 10,-y => 5);  
$cb2 = $kcorr_frame->Checkbutton(-text => "$flags[1][0]",-variable => \$flags[1][1],-width => 16,-anchor => 'w')->place(-x => 10, -y => 26); 
$cb3 = $kcorr_frame->Checkbutton(-text => "$flags[2][0]",-variable => \$flags[2][1],-width => 16,-anchor => 'w')->place(-x => 10, -y => 47); 

# Structural Flags
$struct_frame = $main->LabFrame(-label => "Structure Flags", -labelside => "acrosstop",-height => 95,-width => 380)->pack(-side => 'left',-fill => 'y');
$cb4 = $struct_frame->Checkbutton(-text => "$flags[3][0]",-variable => \$flags[3][1],-width => 16,-anchor => 'w')->place(-x => 10,-y => 5);   
$cb5 = $struct_frame->Checkbutton(-text => "$flags[4][0]",-variable => \$flags[4][1],-width => 16,-anchor => 'w')->place(-x => 10,-y => 27);          
$cb6 = $struct_frame->Checkbutton(-text => "$flags[5][0]",-variable => \$flags[5][1],-width => 16,-anchor => 'w')->place(-x => 10,-y => 49);    
$cb7 = $struct_frame->Checkbutton(-text => "$flags[6][0]",-variable => \$flags[6][1],-width => 16,-anchor => 'w')->place(-x => 10,-y => 71);    

$cb8  = $struct_frame->Checkbutton(-text => "$flags[7][0]",-variable => \$flags[7][1],-width => 16,-anchor => 'w')->place(-x => 115,-y => 5);   
$cb9  = $struct_frame->Checkbutton(-text => "$flags[8][0]",-variable => \$flags[8][1],-width => 16,-anchor => 'w')->place(-x => 115,-y => 27);          
$cb10 = $struct_frame->Checkbutton(-text => "$flags[9][0]",-variable => \$flags[9][1],-width => 16,-anchor => 'w')->place(-x => 115,-y => 49);    
$cb11 = $struct_frame->Checkbutton(-text => "$flags[10][0]",-variable => \$flags[10][1],-width => 16,-anchor => 'w')->place(-x => 115,-y => 71);    

$cb12  = $struct_frame->Checkbutton(-text => "$flags[11][0]",-variable => \$flags[11][1],-width => 18,-anchor => 'w')->place(-x => 225,-y => 5);   
$cb13  = $struct_frame->Checkbutton(-text => "$flags[12][0]",-variable => \$flags[12][1],-width => 18,-anchor => 'w')->place(-x => 225,-y => 27);          
$cb14 = $struct_frame->Checkbutton(-text => "$flags[13][0]",-variable => \$flags[13][1],-width => 18,-anchor => 'w')->place(-x => 225,-y => 49);    
$cb15 = $struct_frame->Checkbutton(-text => "$flags[14][0]",-variable => \$flags[14][1],-width => 18,-anchor => 'w')->place(-x => 225,-y => 71);    

# Quality Flags
$struct_frame = $main->LabFrame(-label => "Quality Flags", -labelside => "acrosstop",-height => 95,-width => 150)->pack(-side => 'left',-fill => 'y');
$cb16 = $struct_frame->Checkbutton(-text => "$flags[15][0]",-variable => \$flags[15][1],-width => 18,-anchor => 'w')->place(-x => 10,-y => 5);   
$cb17 = $struct_frame->Checkbutton(-text => "$flags[16][0]",-variable => \$flags[16][1],-width => 18,-anchor => 'w')->place(-x => 10,-y => 27);          
$cb18 = $struct_frame->Checkbutton(-text => "$flags[17][0]",-variable => \$flags[17][1],-width => 18,-anchor => 'w')->place(-x => 10,-y => 49);    






# Read Name of Source List
$srclst = shift(@ARGV) || die $usage;

read_source_list();

# Read Arguments
$command_line_input = 0;
$silent = 0;
$resetds9 = 1;

while($arg = shift(@ARGV)) 
{
    if ($arg =~ /^-o/) {
	$openfile = shift(@ARGV);
	$command_line_input = 1;
    }
    if ($arg =~ /^-s/) {
	$silent = 1;
    }
    if ($arg =~ /^-p/) {
	$path = shift(@ARGV);
    }
    if ($arg =~ /^-n/) {
	$resetds9 = 0;
    }
}

first_source();

# Load previous classifications if provided
if ($command_line_input) { open_prev(); }


MainLoop;




sub button_disk {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Spiral was previously clicked, clear it
    $morphstate_local = @morphstate[0];
    if ($morphstate_local == 1) { clear_disk(); } 
    
    # If Spiral has not been clicked, enter here
    if ($morphstate_local == 0) { 
	$catcb[0]->configure(-background => 'lightgreen'); 
	$morphstate[0] = 1;

	$morphstate_spheroid = @morphstate[1];
#	if (($morphstate_local == 0) && ($morphstate_spheroid == 0)) { 
#	    $flags[11][1] = 1;  # Click Disk Dominated Flag
#	}
#	if (($morphstate_local == 0) && ($morphstate_spheroid == 1)) { 
#	    $flags[11][1] = 0;  # Clear Disk Dominated Flag
#	    $flags[12][1] = 0;  # Clear Spheroid Dominated Flag
#	}
    }
}

sub button_spheroid {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Spheroid was previously clicked, clear it
    $morphstate_local = @morphstate[1];
    if ($morphstate_local == 1) { clear_spheroid(); } 
    
    # If Spheroid has not been clicked, enter here
    if ($morphstate_local == 0) { 
	$catcb[1]->configure(-background => 'lightgreen');
	$morphstate[1] = 1;

	$morphstate_disk = @morphstate[0];
#	if (($morphstate_local == 0) && ($morphstate_disk == 0)) { 
#	    $flags[12][1] = 1;  # Click Spheroid Dominated Flag
#	}
#	if (($morphstate_local == 0) && ($morphstate_disk == 1)) { 
#	    $flags[11][1] = 0;  # Clear Disk Dominated Flag
#	    $flags[12][1] = 0;  # Clear Spheroid Dominated Flag
#	}
    }
}

sub button_irr {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $morphstate_local = @morphstate[2];
    if ($morphstate_local == 1) { clear_irr(); } 

    # If Irregular has not been clicked, enter here
    if ($morphstate_local == 0) { 
	$catcb[2]->configure(-background => 'lightgreen');
	$morphstate[2] = 1;

	$flags[6][1] = 1;  # Click Asymmetric Flag
    }
}

sub button_compact {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $morphstate_local = @morphstate[3];
    if ($morphstate_local == 1) { clear_compact(); } 

    # If Spheroid has not been clicked, enter here
    if ($morphstate_local == 0) { 
	$catcb[3]->configure(-background => 'lightgreen');
	$morphstate[3] = 1;
    }
}

sub button_uncl {

    # Unclassifiable has been clicked
    # First clear all other buttons
#    clear_btns();
#    $morphstate[0] = 0;
#    $morphstate[1] = 0;
#    $morphstate[2] = 0;
#    $morphstate[3] = 0;
#    $morphstate[4] = 0;
#    $morphstate[5] = 0;
    
    # If Unclassifiable was previously clicked, clear it...
    $morphstate_local = @morphstate[4];
    if ($morphstate[4] == 1) { 
	clear_uncl(); 
 	$morphstate[4] = 0;
    }

    if ($morphstate_local == 0) { 
	$catcb[4]->configure(-background => 'lightgreen');
	$morphstate[4] = 1;
    }
}


sub button_merger {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $intstate_local = $intstate;
#   if ($morphstate_local == 1) { clear_merger(); } 

    # If Spheroid has not been clicked, enter here
    if ($intstate_local != 1) { 
	clear_int_btns();
	$catcb[5]->configure(-background => 'lightgreen');
	$intstate = 1;
    }
}


sub button_int1 {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $intstate_local = $intstate;
#   if ($morphstate_local == 1) { clear_int1(); } 

    # If Spheroid has not been clicked, enter here
    if ($intstate_local != 2) { 
	clear_int_btns();
	$catcb[6]->configure(-background => 'lightgreen');
	$intstate = 2;
    }
}


sub button_int2 {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $intstate_local = $intstate;
#   if ($morphstate_local == 1) { clear_int2(); } 

    # If Spheroid has not been clicked, enter here
    if ($intstate_local != 3) { 
	clear_int_btns();
	$catcb[7]->configure(-background => 'lightgreen');
	$intstate = 3;
    }
}


sub button_pair {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $intstate_local = $intstate;
#    if ($morphstate_local == 1) { clear_pair(); } 

    # If Spheroid has not been clicked, enter here
    if ($intstate_local != 4) { 
	clear_int_btns();
	$catcb[8]->configure(-background => 'lightgreen');
	$intstate = 4;
    }
}


sub button_none {

#    # If Unclassifiable was clicked, clear it
#    if ($morphstate[6] == 1) { clear_uncl(); }

    # If Irregular was previously clicked, clear it
    $intstate_local = $intstate;
#    if ($morphstate_local == 1) { clear_pair(); } 

    # If Spheroid has not been clicked, enter here
    if ($intstate_local != 0) { 
	clear_int_btns();
	$catcb[9]->configure(-background => 'lightgreen');
	$intstate = 0;
    }
}




sub make_clump_window {

$clumpwin = $main->Toplevel();
$clumpwin->title("CANDELS Morph Classifier");
$clumpwin->resizable(0, 0);

# Make Info / Progress Frame
$info2 = "Loading source list...";
$infoframe2 = $clumpwin->Label(-textvariable => \$info, -relief => 'groove', -background => 'IndianRed1')->pack(-side => 'bottom', -fill => 'x');

# Make Next & Exit Buttons
$sb = $clumpwin->Frame(-relief => 'flat', -borderwidth => 5);
# $sb = $clumpwin->LabFrame(-label => "Navigation Controls", -labelside => "acrosstop", -borderwidth => 2);
$sb->pack(-side => 'bottom', -anchor => 's', -expand => 0);
# $exit = $sb->Button(-text => "Exit",-command => sub {exit})->pack(-side => 'left',-padx => 2);
$help = $sb->Button(-text => "Jump To",-command => \&jump_popup, -width => 5)->pack(-side => 'left',-padx => 20);
$last = $sb->Button(-text => "Back",-command => \&prev_source, -width => 20)->pack(-side => 'left',-padx => 2);
$next = $sb->Button(-text => "Submit & Next",-command => \&next_source, -width => 38)->pack(-side => 'left',-padx => 2);

# Make DS9 Control Buttons
# $ds9b = $clumpwin->LabFrame(-label => "DS9 Controls", -labelside => "acrosstop", -borderwidth => 2);
$ds9b = $clumpwin->Frame(-relief => 'flat', -borderwidth => 2);
$ds9b->pack(-side => 'bottom', -anchor => 's', -expand => 0);
# $exit = $sb->Button(-text => "Exit",-command => sub {exit})->pack(-side => 'left',-padx => 2);
$segmap_button = $ds9b->Button(-text => "Show Segmap",-command => \&showhide_segmap, -width => 12)->pack(-side => 'left',-padx => 2);
$matchwcs_button = $ds9b->Button(-text => "Match WCS",-command => \&match_wcs, -width => 12)->pack(-side => 'left',-padx => 2);
$matchcolor_button = $ds9b->Button(-text => "Match Stretch",-command => \&match_colorbar, -width => 12)->pack(-side => 'left',-padx => 2);
$invertcolor_button = $ds9b->Button(-text => "Invert Colormap",-command => \&invert_colormap, -width => 12)->pack(-side => 'left',-padx => 2);
$resetframe_button = $ds9b->Button(-text => "Reset Frames",-command => \&reset_frames, -width => 12)->pack(-side => 'left',-padx => 2);

# Make Comment Box 
$comment = "";
$commentframe = $clumpwin->LabEntry(-label => "Additional Comments: ",-labelPack => [ -side => "left" ],-textvariable => \$comment,-width=>35)->pack(-side => 'bottom',-pady => 2);
$commentframe->bind("<Return>",\&raise_comment_box);
$commentframe->bind("<ButtonPress-1>",\&sink_comment_box);


## Clump Stuff

$image_clump1a = $clumpwin->Photo(-file => "./MorphGUI_files/Clump1a.128.jpg",-width => 128, -height => 62);
$image_clump1b = $clumpwin->Photo(-file => "./MorphGUI_files/Clump1b.128.jpg",-width => 128, -height => 62);
$image_clump1c = $clumpwin->Photo(-file => "./MorphGUI_files/Clump1c.128.jpg",-width => 128, -height => 62);

$image_clump2a = $clumpwin->Photo(-file => "./MorphGUI_files/Clump2a.128.jpg",-width => 128, -height => 62);
$image_clump2b = $clumpwin->Photo(-file => "./MorphGUI_files/Clump2b.128.jpg",-width => 128, -height => 62);
$image_clump2c = $clumpwin->Photo(-file => "./MorphGUI_files/Clump2c.128.jpg",-width => 128, -height => 62);

$image_clump3a = $clumpwin->Photo(-file => "./MorphGUI_files/Clump3a.128.jpg",-width => 128, -height => 62);
$image_clump3b = $clumpwin->Photo(-file => "./MorphGUI_files/Clump3b.128.jpg",-width => 128, -height => 62);
$image_clump3c = $clumpwin->Photo(-file => "./MorphGUI_files/Clump3c.128.jpg",-width => 128, -height => 62);

$clumpframe3 = $clumpwin->Frame(-height => 0,-width => 0)->pack(-side => 'bottom', -fill => 'x',-pady => 6);
$filler_frame = $clumpframe3->Frame(-height => 10,-width => 3)->pack(-side => 'left',-fill => 'y');
$clumpthumb1c = $clumpframe3->Label(-image => $image_clump3a)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb1c = $clumpframe3->Checkbutton(-text => "No Major\nClumps\nLots of\nPatchiness",-variable => \$flags[18][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb2c = $clumpframe3->Label(-image => $image_clump3b)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb2c = $clumpframe3->Checkbutton(-text => "1-2 Major\nClumps\nLots of\nPatchiness",-variable => \$flags[19][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb3c = $clumpframe3->Label(-image => $image_clump3c)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb3c = $clumpframe3->Checkbutton(-text => "3+ Major\nClumps\nLots of\nPatchiness",-variable => \$flags[20][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');

$clumpframe2 = $clumpwin->Frame(-height => 0,-width => 0)->pack(-side => 'bottom', -fill => 'x');
$filler_frame = $clumpframe2->Frame(-height => 10,-width => 3)->pack(-side => 'left',-fill => 'y');
$clumpthumb1b = $clumpframe2->Label(-image => $image_clump2a)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb1b = $clumpframe2->Checkbutton(-text => "No Major\nClumps\nSome\nPatchiness",-variable => \$flags[21][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb2b = $clumpframe2->Label(-image => $image_clump2b)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb2b = $clumpframe2->Checkbutton(-text => "1-2 Major\nClumps\nSome\nPatchiness",-variable => \$flags[22][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb3b = $clumpframe2->Label(-image => $image_clump2c)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb3b = $clumpframe2->Checkbutton(-text => "3+ Major\nClumps\nSome\nPatchiness",-variable => \$flags[23][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');

$clumpframe1 = $clumpwin->LabFrame(-label => "Clump Analysis:", -labelside => "acrosstop",-height => 0,-width => 0,-relief => 'flat',-foreground => 'DarkRed')->pack(-side => 'bottom', -fill => 'x');
$clumpthumb1a = $clumpframe1->Label(-image => $image_clump1a)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb1a = $clumpframe1->Checkbutton(-text => "No Major\nClumps\nNo\nPatchiness",-variable => \$flags[24][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb2a = $clumpframe1->Label(-image => $image_clump1b)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb2a = $clumpframe1->Checkbutton(-text => "1-2 Major\nClumps\nNo\nPatchiness",-variable => \$flags[25][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');
$clumpthumb3a = $clumpframe1->Label(-image => $image_clump1c)->pack(-side => 'left',-anchor => 'w',-padx => 1,-fill => 'both');
$clumpcb3a = $clumpframe1->Checkbutton(-text => "3+ Major\nClumps\nNo\nPatchiness",-variable => \$flags[26][1],-width => 10,-anchor => 'w')->pack(-side => 'left',-anchor => 'w',-fill => 'both');

}



sub initialize {

    clear_btns();

    # K-correction
    @flags[0] = ["V-band Different",0,8,"foo","\@mrg"];        
    @flags[1] = ["z-band Different",0,8,"foo","\@mrg"];        
    @flags[2] = ["J-band Different",0,8,"foo","\@mrg"];        

    # Structural Stuff
    @flags[3] = ["Bar",0,8,"foo","\@mrg"];        
    @flags[4] = ["Spiral Arms",0,8,"foo","\@mrg"];        
    @flags[5] = ["Tidal Arms",0,8,"foo","\@mrg"];        
    @flags[6] = ["Asymmetric",0,8,"foo","\@mrg"];        

    @flags[7] = ["Edge-on Disk",0,8,"foo","\@mrg"];        
    @flags[8] = ["Face-on Disk",0,8,"foo","\@mrg"];        
    @flags[9] = ["Tad Pole",0,8,"foo","\@mrg"];        
    @flags[10] = ["Chain Galaxy",0,8,"foo","\@mrg"];        
 
    @flags[11] = ["Disk Dominated",0,8,"foo","\@mrg"];        
    @flags[12] = ["Bulge Dominated",0,8,"foo","\@mrg"];        
    @flags[13] = ["Double Nuclei",0,8,"foo","\@mrg"];        
    @flags[14] = ["Pt Src Contamination",0,8,"foo","\@mrg"];        
 
    # Quality Flags
    @flags[15] = ["Bad Deblend",0,8,"foo","\@mrg"];        
    @flags[16] = ["Img Qual Problem ",0,8,"foo","\@mrg"];        
    @flags[17] = ["Uncertain",0,8,"foo","\@mrg"];        

    @flags[18] = ["NoClump_NoPatch",0,8,"foo","\@mrg"];        
    @flags[19] = ["OneClump_NoPatch",0,8,"foo","\@mrg"];        
    @flags[20] = ["ThreeClump_NoPatch",0,8,"foo","\@mrg"];        
    @flags[21] = ["NoClump_SomePatch",0,8,"foo","\@mrg"];        
    @flags[22] = ["OneClump_SomePatch",0,8,"foo","\@mrg"];        
    @flags[23] = ["ThreeClump_SomePatch",0,8,"foo","\@mrg"];        
    @flags[24] = ["NoClump_LotsPatch",0,8,"foo","\@mrg"];        
    @flags[25] = ["OneClump_LotsPatch",0,8,"foo","\@mrg"];        
    @flags[26] = ["ThreeClump_LotsPatch",0,8,"foo","\@mrg"];        

    $allflags = 0;
    $nflags = 26;

    $morphstate_local = 0;
    @morphstate[0] = 0;
    @morphstate[1] = 0;
    @morphstate[2] = 0;
    @morphstate[3] = 0;
    @morphstate[4] = 0;

    $intstate = 0;

    $nmorphs = 4;
    $nints = 4;

    foreach $i (0..$nflags) {
	$flags[$i][1] = 0;
    }

    $contour_state = 0;  # Segmap contours are off
    $comment = "";       # Set comment to null

}

sub reset_gui {   

    clear_btns();

    # Flags
    # If new source, reset flags 
    # If previously visited, show prev results
    foreach $i (0..$nflags) {
	$flags[$i][1] = $masterflags[$i][$mastercounter];
    }

    # Morph Class
    # If previously visited, show prev results
     foreach $i (0..$nmorphs) {
	$morphstate[$i] = $masterclass[$i][$mastercounter];
	$morphstate_local = @morphstate[$i];
	if ($morphstate_local == 1) { 
	    $catcb[$i]->configure(-background => 'lightgreen'); 
	}
    }

    # Int Class
    # If new source, reset flags 
    # If previously visited, show prev results
    $intstate = $masterint[$mastercounter];
    $intstate_local = $intstate;

    if ($intstate_local == 0) { 
	$catcb[9]->configure(-background => 'lightgreen'); 
    }
    if ($intstate_local != 0) { 
	$catcb[9]->configure(-background => "#AAAFC3"); 
	$i = 5+($intstate_local-1);
	$catcb[$i]->configure(-background => 'lightgreen'); 
    }


    # Comments
    $comment = $comments[$mastercounter];
  
    update_info_panel();

    $morphstate_local = 0;
    $intstate_local = 0;
    hide_segmap();
}



sub clear_btns {
    foreach $i (0..8) {
	$catcb[$i]->configure(-background => "#AAAFC3"); 
    }
    $catcb[9]->configure(-background => "lightgreen");  # Default is undisturbed 
}

sub clear_int_btns {
    foreach $i (5..9) {
	$catcb[$i]->configure(-background => "#AAAFC3"); 
    }
}

sub clear_disk {
    $catcb[0]->configure(-background => "#AAAFC3"); 
    $morphstate[0] = 0;
#   $flags[11][1] = 0;

    $morphstate_spheroid = @morphstate[1];
#    if ($morphstate_spheroid == 1) {
#	$flags[12][1] = 1;  # Click Spheroid Dominated Flag
#    }
}
sub clear_spheroid {
    $catcb[1]->configure(-background => "#AAAFC3"); 
    $morphstate[1] = 0;
#   $flags[12][1] = 0;

    $morphstate_disk = @morphstate[0];
#    if ($morphstate_disk == 1) {
#	$flags[11][1] = 1;  # Click Disk Dominated Flag
#    }
}
sub clear_irr {
    $catcb[2]->configure(-background => "#AAAFC3"); 
    $morphstate[2] = 0;

    $flags[6][1] = 0;  # Clear Asymmetric Flag
}
sub clear_compact {
    $catcb[3]->configure(-background => "#AAAFC3"); 
    $morphstate[3] = 0;
}
sub clear_uncl {
    $catcb[4]->configure(-background => "#AAAFC3"); 
    $morphstate[4] = 0;
}

sub clear_merger {
    $catcb[5]->configure(-background => "#AAAFC3"); 
    $intstate = 0;
}
sub clear_int1 {
    $catcb[6]->configure(-background => "#AAAFC3"); 
    $intstate = 0;
}
sub clear_int2 {
    $catcb[7]->configure(-background => "#AAAFC3"); 
    $intstate = 0;
}
sub clear_pair {
    $catcb[8]->configure(-background => "#AAAFC3"); 
    $intstate = 0;
}
sub clear_none {
    $catcb[9]->configure(-background => "#AAAFC3"); 
    $intstate = 1;
}




sub read_source_list {

    @sources = split("\n", `cat $srclst`);
    $nsources = scalar(@sources);
    $mastercounter = 0;

    print STDERR "\nReading source list ... $nsources sources found.\n";

    for $i (0..$nsources-1) {

	foreach $j (0..$nmorphs) {
	    $masterclass[$j][$i] = 0;
	}

	$masterint[$i] = 0;

	foreach $j (0..$nflags) {
	    $masterflags[$j][$i] = 0;
	}

	$classified[$i] = 0;
	$comments[$i] = "";
    }
}


sub first_source {

    $source = $sources[0];
    ($srcim,$temp) = split("_h.fits",$source);
    # print STDERR "Current Source: $srcim (1/$nsources)\n";
    $info = "Viewing Source $srcim (1/$nsources)";

    $Vimg = $path.$srcim."_v.fits";
    $Zimg = $path.$srcim."_z.fits";
    $Jimg = $path.$srcim."_j.fits";
    $Himg = $path.$srcim."_h.fits";
    $Simg = $path.$srcim."_segmap.fits";

    display_first_source();
}


sub load_thumbnails {

    $source = $sources[$mastercounter];
    ($srcim,$temp) = split("_h.fits",$source);

    $mastercounter2 = $mastercounter+1;
    $info = "Viewing Source $srcim ($mastercounter2/$nsources)";

    $Vimg = $path.$srcim."_v.fits";
    $Zimg = $path.$srcim."_z.fits";
    $Jimg = $path.$srcim."_j.fits";
    $Himg = $path.$srcim."_h.fits";
    $Simg = $path.$srcim."_segmap.fits";
}




sub next_source {
    
    save_state();

    $mastercounter++;
    reset_gui();

    # Load & Display Thumbnails
    load_thumbnails();
    display_source();

    # Reset Comment Box
#   $comment = "";
    $commentframe->configure(-relief => sunken);

    update_info_panel();

    if ($mastercounter+1 == $nsources) {
	final_source();
    }
}


sub prev_source {
    
    if ($mastercounter != 0) {
	$mastercounter = $mastercounter-1;
    }
    reset_gui();

    # Load & Display Thumbnails
    load_thumbnails();
    display_source();

    # Reset Comment Box
#   $comment = "";
    $commentframe->configure(-relief => sunken);

    update_info_panel();

    if ($mastercounter+1 != $nsources) {
	$next->configure(-text => "Submit & Next", -command => \&next_source);
    }
}


sub final_source {
    $next->configure(-text => "Finish", -command => \&finish);
}


sub finish {
    save_state();
    save_curr();
#   exit;
}


sub save_curr {

    save_file();
   
    $savefile2 = ">".$savefile;
    open output, $savefile2;

    # Get time of day for header
    @timeData = localtime(time);
    $time = "$timeData[2]:$timeData[1]:$timeData[0]";
    $month = $timeData[4]+1;
    $year = $timeData[5]+1900;
    $date = "$month/$timeData[3]/$year";    

    # Print Header Info
    print output "$srclst\n";
    print output "$date : $time\n";
    print output "Morphology: Spheroid, Disk, Irregular/Pec, Compact/Unresolved, Unclassifiable\n";
    print output "Interaction: Merger, Interaction within segmap, Interaction beyond segmap, Non-interacting Projected Close Pair\n";
    print output "Clumpiness/Patchiness(0:none, 1:some, 2:many): C0P0, C1P0, C2P0, C0P1, C1P1, C2P1, C0P2, C1P2, C2P2\n";
    print output "Flags: Bad Deblend, Img Qual Prob, Uncertain, Vband-morph diff, zband-morph diff, Jband-morph diff, Tidal Arms, Double Nuclei, Asymmetric, Spiral Arms, Bar, Pt Source Contamination, Edge-on, Face-on, Tad Pole, Chain, Disk Dominated, Bulge Dominated, COMMENTS\n";

    foreach $i (0..$nsources-1) {
	($src,$temp) = split("_h.fits",$sources[$i]);
	print output "$src,";

	# Print Morph Class (1 or 0)
	print output "$masterclass[1][$i],";   # This is here to match Mark's order of Sph,Disk...
	print output "$masterclass[0][$i],";
	foreach $j (2..$nmorphs) {
	    print output "$masterclass[$j][$i],";
	}
	# Print Int Class (0 through 4)
	print output "$masterint[$i],";

#	foreach $k (0..$nflags) {
	@flag_order_mozena = (24,25,26,21,22,23,18,19,20, 15,16,17, 0,1,2, 5,13,6,4,3,14,7,8,9,10,11,12);
	foreach $k (@flag_order_mozena) {
	    print output "$masterflags[$k][$i],"; 
	}
#	print output "$classified[$i],";  # remove this later

	# If comment is null, then set it to 0 (for mozena)
	if ($comments[$i] eq "") {
	    	print output "0\n";
	} else {
	    print output "$comments[$i]\n";
	}
    }
    # Print dummy line at end (for mozena)
    print output ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\n";
}


sub open_prev {

    # If input file specified in command line
    # then don't bring up open panel
    if (!$command_line_input) {
	open_file();
    }
    $command_line_input = 0;  # reset this

    # Enter this loop only if input file specified
    # If user hits cancel in open panel, $openfile
    # will be null.
    if ($openfile) { 

	@input_file = "$openfile";
	$input = shift(@input_file) || die $usage;
	@lines = split("\n", `cat $input`);

	# remove last dummy line (for mozena)
	$mozena_line = pop(@lines);

	@lines = reverse(@lines);
	$line1 = pop(@lines);
	$line2 = pop(@lines);
	$line3 = pop(@lines);
	$line4 = pop(@lines);
	$line5 = pop(@lines);
	$line6 = pop(@lines);
	@lines = reverse(@lines);
	
	$nsources = scalar(@sources);
	print STDERR "Reading Previous Classifications from $openfile ... ";
	
	$i = 0;
	foreach $line (@lines) {
#	for $i (0..$nsources-1) {
	    
#	    print STDERR "$line\n";
	    @prevclass = split(",", $line);
	    
	    # Morph Class
	    $masterclass[1][$i] = $prevclass[0+1];
	    $masterclass[0][$i] = $prevclass[1+1];
	    foreach $j (2..$nmorphs) {
		$masterclass[$j][$i] = $prevclass[$j+1];
#		print STDERR "master class: $prevclass[$j+1]\n";
	    }

	    # Int Class
	    $masterint[$i] = $prevclass[($nmorphs+2)];
	    $crap = $prevclass[6];
#	    print STDERR "master int: $prevclass[($nmorphs+1)] $crap\n";

	    # Flags
	    $kk = 0;
  	    @flag_order_mozena = (24,25,26,21,22,23,18,19,20, 15,16,17, 0,1,2, 5,13,6,4,3,14,7,8,9,10,11,12);
	    foreach $k (@flag_order_mozena) {
#	    foreach $k (0..$nflags) {	       
		$masterflags[$k][$i] = $prevclass[$kk+1+($nmorphs+2)];
		$kk++;
	    }
	    
	    # Now handle the comments
	    $nprevclass = scalar(@prevclass);
	    $comment_prev = "";
	    foreach $ll (34..($nprevclass-1)) {
		$comment_prev = $comment_prev.$prevclass[$ll]." ";
	    }
	    # If comment is 0, then set it to null
	    if ($comment_prev eq "0 ") { 
		$comment_prev = ""; 
	    }
	    $comments[$i] = $comment_prev;
	    
	    # Mark as classified and advance
	    $anymorph = 0;
	    foreach $j (0..$nmorphs) {
		$morph_test = $masterclass[$j][$i];
		if ($morph_test == 1) {
		    $anymorph = 1;
		}
	    }
	    if ($anymorph == 1) {
		$classified[$i] = 1    
	    }

#	    $morphsum = 0;
#	    foreach $j (0..$nmorphs) { $morphsum = $morphsum + $masterclass[$j][$i]; }
#	    if ($morphsum != 0) {
#		$classified[$i] = 1;
#	    }

	    $i++;   # Advance Counter
	}

	jump_to_unclass_source();
	if ($silent == 0) { open_popup2(); }
	print STDERR "Done.\n";
    }
}


# Open File Browser
sub open_file {
  $openfile = $main->getOpenFile(-filetypes => $filetypes,
                                -defaultextension => '.dat',
                                -initialfile => 'morphgui_output.dat');
}

# Save File Browser
sub save_file {
  $savefile = $main->getSaveFile(-filetypes => $filetypes, 
				 -defaultextension => '.pl',
				 -initialfile => 'morphgui_output.dat');
}



# Show results of load call
sub open_popup2 {  
   $openpop = $main->Toplevel();
   $openpop->title("Status");
   $openpop->resizable(0, 0);	    

   $mastercounter2 = $mastercounter+1;
   $topenpop = "Previous Classifications Loaded From:\n$openfile\n\n Jumping to source $srcim ($mastercounter2/$nsources)\n";
   $bopenpop = $openpop->Frame(-relief => 'flat', -borderwidth => 2)->pack(-side => 'bottom', -fill => 'x');
   $lopenpop = $openpop->Label(-textvariable => \$topenpop, -relief => 'flat')->pack(-side => 'top', -fill => 'x', -padx => 5, -pady => 5);
   $bopenpop->Button(-text => "Close", -command => sub { $openpop->destroy(); })->pack(-side => 'bottom', -padx => 5);
}



sub jump_to_unclass_source {
    $i = 0;
    $jump = 0;
    while ($jump == 0) {
	$classified_local = $classified[$i];
	if ($i+1 == $nsources) {  ;  # this way if all sources classified, gui will go to last source
	    $jump = 1;
	    $mastercounter = $i;
	}
	if ($classified_local == 0) {
	    $jump = 1;
	    $mastercounter = $i;
	}
	$i++;
    }
    reset_gui();
    load_thumbnails();
    display_source();

    # Update Info text
    $source = $sources[$mastercounter];
    ($srcim,$temp) = split(".H_ERS.fits",$source);
    $mastercounter2 = $mastercounter+1;
    $info = "Viewing Source $srcim ($mastercounter2/$nsources)";

    if ($mastercounter+1 == $nsources) {
	final_source();
    }
}


sub update_info_panel {

    # Make info panel green if previously classified
    if ($classified[$mastercounter] == 1) {
	$infoframe-> configure(-background => 'lightgreen'); 
	$infoframe2-> configure(-background => 'lightgreen'); 
    }
    # Otherwise keep it red
    if ($classified[$mastercounter] == 0) {
	$infoframe-> configure(-background => 'IndianRed1'); 
	$infoframe2-> configure(-background => 'IndianRed1'); 
    }
}




sub jump_popup {

    if ($jumpopen) { $jumppop->destroy(); }
    $jumpopen = 1;

    $jumppop = $main->Toplevel();
    $jumppop->title("Jump");
    $jumppop->resizable(0, 0);

    $jump_buttons = $jumppop->Frame(-relief => 'flat', -borderwidth => 5)->pack(-side => 'bottom', -anchor => 's', -expand => 0);
    $jump_jump = $jump_buttons->Button(-text => "Jump", -command => \&jump)->pack(-side => 'left',-padx => 2);
    $jump_exit = $jump_buttons->Button(-text => "Cancel", -command => sub { $jumpopen = 0; $jumppop->destroy();  })->pack(-side => 'left',-padx => 2);

    $jump_inst = "Select Source and Click Jump";
    $jumppop->Label(-textvariable => \$jump_inst)->pack(-side => 'bottom',-pady => 2);

    # Create Listbox 
    $listbox = $jumppop->Scrolled("Listbox", -scrollbars => "w",-width => 40,-height => 15)->pack(-side => "left");

    foreach $j (0..$nsources-1) {
	$source = $sources[$j];
	($srcim,$temp) = split(".H_ERS.fits",$source);
	
	$classified_local = $classified[$j];
	if ($classified_local == 1) {
	    $num = $j+1;
	    $status_text = " ".$num." - ".$srcim." - Completed";
	    $listbox->insert('end', " ".$status_text);
#	    $listbox->itemconfigure($j, -foreground => 'blue');
	    $listbox->itemconfigure($j, -background => 'lightgreen');
	}
	if ($classified_local == 0) {
	    $num = $j+1;
	    $status_text = " ".$num." - ".$srcim." - Unclassified";
	    $listbox->insert('end'," ".$status_text);
#	    $listbox->itemconfigure($j, -foreground => 'red');
	    $listbox->itemconfigure($j, -background => 'indianred1');
	}
    }

}

sub jump {
    @selected = $listbox->curselection;
    $mastercounter = $selected[0];

    $jumppop->destroy();     
    $jumpopen = 0;

    reset_gui();
    load_thumbnails();
    display_source();

    if ($mastercounter+1 == $nsources) {
	final_source();
    }
}


sub display_first_source {

    # Here everything is initialized, even if resetds9 = 0

    echosys("xpaset -p MorphGUI tile");
    echosys("xpaset -p MorphGUI tile column");
    echosys("xpaset -p MorphGUI view info no");
    echosys("xpaset -p MorphGUI view panner no");
    echosys("xpaset -p MorphGUI view magnifier no");
    echosys("xpaset -p MorphGUI view colorbar no");
#   echosys("xpaset -p MorphGUI view buttons no");
    echosys("xpaset -p MorphGUI width 1150");
    echosys("xpaset -p MorphGUI height 230");
   echosys("xpaset -p MorphGUI cmap value 1.0 0.5");

    echosys("xpaset -p MorphGUI frame 1");
    echosys("xpaset MorphGUI fits < $Vimg");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    ($contrast1,$bias1) = `xpaget MorphGUI cmap value`;
    echosys("xpaset -p MorphGUI cmap invert yes"); 

    echosys("xpaset -p MorphGUI frame 2");
    echosys("xpaset MorphGUI fits < $Zimg");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
    echosys("xpaset -p MorphGUI contour no");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    ($contrast2,$bias2) = `xpaget MorphGUI cmap value`;
    echosys("xpaset -p MorphGUI cmap invert yes"); 

    echosys("xpaset -p MorphGUI frame 3");
    echosys("xpaset MorphGUI fits < $Jimg");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    ($contrast3,$bias3) = `xpaget MorphGUI cmap value`;    
    echosys("xpaset -p MorphGUI cmap invert yes"); 

    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset MorphGUI fits < $Himg");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    ($contrast4,$bias4) = `xpaget MorphGUI cmap value`;
    echosys("xpaset -p MorphGUI cmap invert yes"); 

    echosys("xpaset -p MorphGUI frame 5");
    echosys("xpaset MorphGUI fits < $Simg");
    echosys("xpaset -p MorphGUI scale linear");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");

    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset -p MorphGUI match frames wcs");
#   echosys("xpaset -p MorphGUI frame hide 5");
}
 

sub display_source {

    # Here everything is initialized only if resetds9 = 1

    echosys("xpaset -p MorphGUI tile");
    echosys("xpaset -p MorphGUI tile column");
    if ($resetds9) {
	echosys("xpaset -p MorphGUI view info no");
	echosys("xpaset -p MorphGUI view panner no");
	echosys("xpaset -p MorphGUI view magnifier no");
	echosys("xpaset -p MorphGUI view colorbar no");
#       echosys("xpaset -p MorphGUI view buttons no");
	echosys("xpaset -p MorphGUI width 1150");
	echosys("xpaset -p MorphGUI height 230");
#       echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    }

    echosys("xpaset -p MorphGUI frame 1");
    echosys("xpaset MorphGUI fits < $Vimg");
    echosys("xpaset -p MorphGUI zoom to fit");
    if ($resetds9) {
	echosys("xpaset -p MorphGUI scale log");
	echosys("xpaset -p MorphGUI scale zmax");
	echosys("xpaset -p MorphGUI contour no");
        echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
	($contrast1,$bias1) = `xpaget MorphGUI cmap value`;
    }

    echosys("xpaset -p MorphGUI frame 2");
    echosys("xpaset MorphGUI fits < $Zimg");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    if ($resetds9) {
	echosys("xpaset -p MorphGUI scale log");
	echosys("xpaset -p MorphGUI scale zmax");
        echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
	($contrast2,$bias2) = `xpaget MorphGUI cmap value`;
    }

    echosys("xpaset -p MorphGUI frame 3");
    echosys("xpaset MorphGUI fits < $Jimg");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    if ($resetds9) {
	echosys("xpaset -p MorphGUI scale log");
	echosys("xpaset -p MorphGUI scale zmax");
        echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
	($contrast3,$bias3) = `xpaget MorphGUI cmap value`;    
    }

    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset MorphGUI fits < $Himg");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI contour no");
    if ($resetds9) {
	echosys("xpaset -p MorphGUI scale log");
	echosys("xpaset -p MorphGUI scale zmax");
        echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
	($contrast4,$bias4) = `xpaget MorphGUI cmap value`;
    }

    echosys("xpaset -p MorphGUI frame 5");
    echosys("xpaset MorphGUI fits < $Simg");
    echosys("xpaset -p MorphGUI scale linear");
    echosys("xpaset -p MorphGUI scale zmax");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");

    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset -p MorphGUI match frames wcs");
#   echosys("xpaset -p MorphGUI frame hide 5");
}
    

sub save_state {

    foreach $j (0..$nmorphs) {
	$masterclass[$j][$mastercounter] = $morphstate[$j];
    }

    $masterint[$mastercounter] = $intstate;

    foreach $j (0..$nflags) {
	$masterflags[$j][$mastercounter] = $flags[$j][1];
    }

    $comments[$mastercounter] = $comment;

    # If no morph classes selected, then list 
    # source as unfinished.  If any class
    # is selected, then list it as classified.
    $anymorph = 0;
    foreach $i (0..$nmorphs) {
	$morphstate_local = @morphstate[$i];
	if ($morphstate_local == 1) {
	    $anymorph = 1;
	}
    }
    if ($anymorph == 1) {
	$classified[$mastercounter] = 1    
    }
    if ($anymorph == 0) {
	$classified[$mastercounter] = 0    
    }
}
    


  
sub raise_comment_box {
    $commentframe->configure(-relief => raised);
#   $commentframe->configure(-takefocus => 0);
}

sub sink_comment_box {
    $commentframe->configure(-relief => sunken);
#   $commentframe->configure(-takefocus => 1);
}


sub about {
   $aboutpop = $main->Toplevel();
   $aboutpop->title("About");
   $aboutpop->resizable(0, 0);	    

   $taboutpop = "CANDELS Morph GUI\nVersion 9.0\n\n by\nDale Kocevski\n\n Report bugs to dale.kocevski\@colby.edu";
   $baboutpop = $aboutpop->Frame(-relief => 'flat', -borderwidth => 2)->pack(-side => 'bottom', -fill => 'x');
   $laboutpop = $aboutpop->Label(-textvariable => \$taboutpop, -relief => 'flat')->pack(-side => 'top', -fill => 'x', -padx => 5, -pady => 5);
   $baboutpop->Button(-text => "Close", -command => sub { $aboutpop->destroy(); })->pack(-side => 'bottom', -padx => 5);
}


sub tutorial {
    $tutpop = $main->Toplevel();
    $tutpop->title("Help / Tutorial");
    $tutpop->resizable(0, 0);	    
    
    $ttutpop = "For more information on the visual classification\n scheme employed in the GUI, please refer to:\n\n http://candels.ucolick.org/wiki/Structure/VisClassDescript\n\n For more information about the GUI itself, please refer to:\n\nhttp://candels.ucolick.org/wiki/Structure/MorphGui";
    $btutpop = $tutpop->Frame(-relief => 'flat', -borderwidth => 2)->pack(-side => 'bottom', -fill => 'x');
    $ltutpop = $tutpop->Label(-textvariable => \$ttutpop, -relief => 'flat')->pack(-side => 'top', -fill => 'x', -padx => 5, -pady => 5);
    $btutpop->Button(-text => "Close", -command => sub { $tutpop->destroy(); })->pack(-side => 'bottom', -padx => 5);
}



sub show_segmap {
    echosys("xpaset -p MorphGUI frame 5");
    echosys("xpaset -p MorphGUI contour method smooth");
    echosys("xpaset -p MorphGUI contour scale sqrt");

    ($segmin,$segmax) = `xpaget MorphGUI scale limits`;

    echosys("xpaset -p MorphGUI contour limits $segmin $segmax");
    echosys("xpaset -p MorphGUI contour nlevels 10");
    echosys("xpaset -p MorphGUI contour smooth 1");
    echosys("xpaset -p MorphGUI contour generate");
    echosys("xpaset -p MorphGUI contour yes");
    echosys("xpaset -p MorphGUI contour copy");
#   echosys("xpaset -p MorphGUI frame hide 5");

    echosys("xpaset -p MorphGUI frame 1");
    echosys("xpaset -p MorphGUI contour paste wcs red 2 no");
    echosys("xpaset -p MorphGUI frame 2");
    echosys("xpaset -p MorphGUI contour paste wcs red 2 no");
    echosys("xpaset -p MorphGUI frame 3");
    echosys("xpaset -p MorphGUI contour paste wcs red 2 no");
    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset -p MorphGUI contour paste wcs red 2 no");

    $contour_state = 1;
    $segmap_button->configure(-text => "Hide Segmap");
}


sub hide_segmap {
    echosys("xpaset -p MorphGUI frame 1");
    echosys("xpaset -p MorphGUI contour clear");
    echosys("xpaset -p MorphGUI frame 2");
    echosys("xpaset -p MorphGUI contour clear");
    echosys("xpaset -p MorphGUI frame 3");
    echosys("xpaset -p MorphGUI contour clear");
    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset -p MorphGUI contour clear");
    echosys("xpaset -p MorphGUI frame 5");
    echosys("xpaset -p MorphGUI contour clear");
#   echosys("xpaset -p MorphGUI frame hide 5");

    $contour_state = 0;
    $segmap_button->configure(-text => "Show Segmap");
}

sub showhide_segmap {

    if ($contour_state == 0) {
	show_segmap();
    } else {
	hide_segmap();
    }

}

sub match_colorbar {
    echosys("xpaset -p MorphGUI match scales");
    echosys("xpaset -p MorphGUI match colorbars");
}

sub reset_frames {
    echosys("xpaset -p MorphGUI frame 1");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap invert yes");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    echosys("xpaset -p MorphGUI contour no");

    echosys("xpaset -p MorphGUI frame 2");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap invert yes");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    echosys("xpaset -p MorphGUI contour no");

    echosys("xpaset -p MorphGUI frame 3");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap invert yes");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    echosys("xpaset -p MorphGUI contour no");

    echosys("xpaset -p MorphGUI frame 4");
    echosys("xpaset -p MorphGUI scale log");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap invert yes");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    echosys("xpaset -p MorphGUI contour no");

    echosys("xpaset -p MorphGUI frame 5");
    echosys("xpaset -p MorphGUI scale linear");
    echosys("xpaset -p MorphGUI scale zmax");
#   echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI zoom to fit");
    echosys("xpaset -p MorphGUI cmap value 1.0 0.5");
    echosys("xpaset -p MorphGUI contour no");
}

sub match_wcs {
    echosys("xpaset -p MorphGUI match frames wcs");
}

sub invert_colormap {
    $colormap_state = `xpaget MorphGUI cmap invert`;
    if ($colormap_state =~ 'yes') { 
	echosys("xpaset -p MorphGUI frame 1");
	echosys("xpaset -p MorphGUI cmap invert no"); 
	echosys("xpaset -p MorphGUI frame 2");
	echosys("xpaset -p MorphGUI cmap invert no"); 
	echosys("xpaset -p MorphGUI frame 3");
	echosys("xpaset -p MorphGUI cmap invert no"); 
	echosys("xpaset -p MorphGUI frame 4");
	echosys("xpaset -p MorphGUI cmap invert no"); 
    }
    if ($colormap_state =~ 'no') { 
	echosys("xpaset -p MorphGUI frame 1");
	echosys("xpaset -p MorphGUI cmap invert yes"); 
	echosys("xpaset -p MorphGUI frame 2");
	echosys("xpaset -p MorphGUI cmap invert yes"); 
	echosys("xpaset -p MorphGUI frame 3");
	echosys("xpaset -p MorphGUI cmap invert yes"); 
	echosys("xpaset -p MorphGUI frame 4");
	echosys("xpaset -p MorphGUI cmap invert yes"); 
    }
}


sub echosys {
#        warn ("# ", $_[0], "\n");
        system($_[0]) && die "$0 : system call ($_[0]) failed\n";
}














