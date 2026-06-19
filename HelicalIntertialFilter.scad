//    HelicalFilter - OpenSCAD program for parametrized Helical Filter
//    Copyright (C) 2027  Robert L. Read
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as
//    published by the Free Software Foundation, either version 3 of the
//    License, or (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.



// =================== BEGIN INCLUDED CODE ================ 
// by varnerrants is licensed under the Creative Commons - Attribution license.

// Super-Duper Parametric Hose Barb

// This is for the manometer hose
// Hose Outer Diameter (used to calculate shlouder length)
hose_od = 5;
// Hose Inner Diameter
hose_id = 2.5;

// How far the barbs swell the diameter.
swell = 1.5;

// Wall thickness of the barb.
wall_thickness = 1.31;

// Number of barbs.
barbs = 3;
// How far between each barb section?
barb_length = 2;

// Do you want to render the outer shell?
shell = true;

// Do you want to render the bore?
bore = true;

// Flattens the barbs on one end. Usefull if youre printing barbs at angles, as the flattened side can be rotated downward facing the bed.
ezprint = false;

// barb(hose_od = hose_od, hose_id = hose_id, swell = swell, wall_thickness = wall_thickness, barbs = barbs, barb_length = barb_length, shell = shell, bore = bore, ezprint = ezprint);


module barb(hose_od = 21.5, hose_id = 15, swell = 1, wall_thickness = 1.31, barbs = 3, barb_length = 2, shell = true, bore = true, ezprint = true) {
    echo("hose_id", hose_id);
    id = hose_id - (2 * wall_thickness);
    translate([0, 0, -((barb_length * (barbs + 1)) + 4.5 + (hose_od - hose_id))])
    difference() {
        union() {
            if (shell == true) {
                cylinder(d = hose_id, h = barb_length);
                for (z = [1 : 1 : barbs]) {
                    translate([0, 0, z * barb_length]) cylinder(d1 = hose_id, d2 = hose_id + swell, h = barb_length);
                }
                translate([0, 0, barb_length * (barbs + 1)]) cylinder(d = hose_id, h = 4.5 + (hose_od - hose_id));
            }
        }
        if (bore == true) {
//            translate([0, 0, -1]) cylinder(d = id, h = (barb_length * (barbs + 1)) + 4.5 + (hose_od - hose_id) + 1);
           translate([0, 0, -1]) cylinder(d = id, h = 1+ (barb_length * (barbs + 1)) + 4.5 + (hose_od - hose_id) + 1);
        }
        if (ezprint == true) {
            difference() {
                cylinder(d = hose_id + (swell * 3), h = (barb_length * (barbs + 1)));
                translate([swell, 0, 0]) cylinder(d = hose_id + (swell * 2), h = (barb_length * (barbs + 1)));
            }
        }
    }
}



// =================== END INCLUDED CODE ================ 

// Questions for John:
// Should the ports have barbs?
// Should the ouutput ports have barb?
// What dimensions do we want?

// TODO: make barbs more flush
// TODO: 

TC_VERSION_NUM = 0.5; // printing helix without bins


// use <BarbGenerator-v3.scad>;


// Params (mm), degrees 

num_bins = 3;
// number_of_complete_revolutions = 2*num_bins;
number_of_revolutions_in_bin = 2;
number_of_complete_revolutions = number_of_revolutions_in_bin*num_bins;
// filter_height_mm = num_bins*40/3;
filter_height_mm = num_bins*120/3;
// WARNING! Trying to reduce this to one bin seemed to make the slit go away

filter_twist_degrees = 360*number_of_complete_revolutions;
// screw_OD_mm = 3.5;
screw_OD_mm = 5.5;
screw_ID_mm = 3.0;
cell_wall_mm = 1;
barb_input_diameter = 2;
barb_output_diameter = 5;
barb_wall_thickness = 1;

// we will use this improve the chance of a good taper fit.
taper_outer_radius_decrease = 2;

// The slit_axial_open_length_mm is the "length",
// in an axial sense of the 
slit_axial_open_length_mm = 2;
// Dubious about this....
slit_axial_length_mm = cell_wall_mm + slit_axial_open_length_mm;
// slit_axial_length_mm = slit_axial_length_mm - cell_wall_mm;

// The "slit_knife" is "radial" in the since that it cuts
// a pie-slice shaped slit into the wall of the helix.
// The wider the angle, the greater the slit. 180 would
// be half the slit. I suggest this be limited to 45 degrees.
slit_knife_angle = 45;
hex_cell_diam_mm = 10;
FN_RES = 120;
$fn = 120;
bin_height_z_mm = 20;
num_screws = 1;

screw_center_separation_mm = 10;

// This is 1.25" in mm to fit inside a normal 
// American vacuum cleaner hose.
// Ideally we would be male (outer_d = 1.25") on one side
// with a female part (inner_d = 1.25" on the other side,
// with a slight taper!
// Note: In practice this needs to be somewhat larger 
// to not "slip into" the pipe (on my vacuum cleaner)
// bin_out_radius = 31.75/2;
bin_out_radius = (31.75 + 3)/2;
// bin_out_radius = 20;
bin_breadth_x_mm = max((num_screws -1) * screw_center_separation_mm + screw_center_separation_mm*2,
    bin_out_radius*2);
    
bin_cutaway_angle = 50;
    
if (bin_breadth_x_mm > bin_out_radius*2) {
    echo("DANGER!! MISFIT!! bin_breadth_x_mm too large!");
}

pitch_mm = filter_height_mm / number_of_complete_revolutions;

scale_ratio = 1.4; // This is used to acheive a more circular air path

bin_wall_thickness_mm = 1;


// CONTROL_VARIABLES
USE_SCREW_ONLY          = 0;
USE_VOIDLESS_SCREW      = 0;
USE_FULL_BINS           = 1;
USE_KNIFE_THRU_SCREWS   = 0;
USE_KNIFE_LOW           = 0;
USE_KNIFE_SIDE          = 0;
USE_KNIFE_TOP_HALF      = 0;
USE_SCREW_KNIFE         = 0;
USE_BARBS               = 0;

USE_FITTING             = 0;

USE_BINCAP              = 0;

USE_FITTING_KNIFE       = 0;

TEST_BARB                = 0;


module Barb(input_diameter,output_diameter) {
    rotate([180,0,0])
    barb(hose_od = input_diameter, hose_id = output_diameter, swell = 2, wall_thickness = barb_wall_thickness, barbs = barbs, barb_length = barb_length, shell = shell, bore = bore, ezprint = ezprint);
}


if (TEST_BARB) {
    jheight = 0;
    translate([15,0,0])
    Barb(barb_input_diameter,barb_output_diameter);
}


// Standalone BinCap generation
//if (USE_BINCAP) {
//    translate([0,0,-bin_height_z_mm+8])
//    BinCap(filter_height_mm,num_bins,bin_height_z_mm,bin_breadth_x_mm, screw_center_separation_mm);
//}

// coordinate system: Gravity points in the -Z direction. +Z is up.abs
// The left-right dimentions is considered X. Air flow is in the positive Y
// direction. The is a right-handed coordinate system.

module Corkscrew(h,twist) {
    rotate([90,0,0])
    linear_extrude(height = h, center = true, convexity = 10, twist = twist, $fn = FN_RES)
    translate([screw_OD_mm, 0, 0])
    scale([1,scale_ratio])
    circle(r = screw_OD_mm);
}


module CorkscrewSlitKnife(twist,depth,num_bins) {
    de = depth/num_bins;
    yrot = 360*(1 / pitch_mm)*de;
    
    // Note: The computation of the slit angle 
    // is a complicated. We create a triangle that 
    // we linearly extruide (in the "polygon" state below.)
    D = 20;
    W = D * tan(slit_knife_angle);
 //   translate([10,0,0])
//    polygon(points = [[0,0],[D,-W],[D,W]]);   

    rotate([90,0,0])
    for(i = [0:num_bins -1]) {
        translate([0,0,-de])
        rotate([0,0,-yrot*(i+1)])
        translate([0,0,(i+1)*de])
        difference() {
            linear_extrude(height = depth, center = true, convexity = 10, twist = twist, $fn = FN_RES)
            translate([screw_OD_mm,0,0])
            rotate([0,0,0])
            polygon(points = [[0,0],[D,-W],[D,W]]);   
            color("blue",0.3)
            translate([0,0,slit_axial_length_mm])
            cube([22,22,depth],center=true);
        }
    }
    
}

module CorkscrewWithVoid(h,twist) {
    rotate([90,0,0])
    linear_extrude(height = h, center = true, convexity = 10, twist = twist, $fn = FN_RES)
    translate([screw_OD_mm, 0, 0])
    difference() {
        scale([1,scale_ratio])
        circle(r = screw_OD_mm);
        scale([1,scale_ratio])
        circle(r = screw_ID_mm);
    }
}

module CorkscrewWithoutVoid(h,twist) {
    echo("CorkscrewWithoutTwist");
    echo(scale_ratio);
    rotate([90,0,0])
    linear_extrude(height = h, center = true, convexity = 10, twist = twist, $fn = FN_RES)
    translate([screw_OD_mm, 0, 0])
    scale([1,scale_ratio])
    circle(r = screw_OD_mm);
}

module CorkscrewWithoutVoidExcess(h,twist) {
    CorkscrewWithoutVoid(h*2,twist*2);
}


module CorkscrewWithSlit(depth,numbins) {
      difference() {
        CorkscrewWithVoid(depth,filter_twist_degrees);
        CorkscrewSlitKnife(filter_twist_degrees,depth,numbins);
    }
 //   translate([10,0,0])
 //   #CorkscrewSlitKnife(filter_twist_degrees,depth,numbins);
}

// Bins module now generates 1/8" NPT female threads instead of barbs.
module Bins(depth,numbins,height,width,height_above_port_line) {
    b = bin_wall_thickness_mm*2;
    bin_radius = width/2;
    // Now I try to do this math to create multiple bins
    // These will be cubes; orifices will have to be cut
    // in them later.
    de = depth/numbins; // w = width of one bin
    intersection() {
        // This puts a slight taper on the system for fitting...
        // Male end is the outlet end (direction of flow out)
        rotate([90,0,0])
        cylinder(de*numbins,bin_radius-taper_outer_radius_decrease,bin_radius+taper_outer_radius_decrease,center = true);
        for(i = [0:numbins -1]) {
            j = -(numbins-1)/2 + i;
            translate([0,j*de,0])
            translate([0,0,height_above_port_line - height/2])
            union() {
                difference() {
                // We can change this cylinder I think...
                    rotate([90,0,0])
                    // we want to put a very slight taper on this cylinder..
                    cylinder(de,bin_radius,bin_radius,center = true);
     //               cube([width,de,height],center = true);
                    // I want the bottom to be opened and then "capped"
                    //translate([0,0,-(b+1)])
                    rotate([90,0,0])
                    cylinder(de-b,bin_radius-b,bin_radius-b,center=true);
     //               cube([width-b,de-b,height-bin_wall_thickness_mm+2],center=true);
                     if (USE_BARBS) {
                        translate([width/2,0,0])
                        rotate([0,90,0])
                        cylinder(b*2,barb_input_diameter,     barb_input_diameter,center=true);
                    }
                } 
                if (USE_BARBS) {
                    translate([width/2 - bin_wall_thickness_mm,0,0])
                    rotate([0,90,0])
                    Barb(barb_input_diameter,barb_output_diameter);
                }
            } 
        }
    }
    

}
module BinsCutaway(depth,numbins,height,width,height_above_port_line) {
    bin_radius = width/2;
    cut_point = (bin_radius)*cos(bin_cutaway_angle);
    s = 1000;
    difference() {
        Bins(depth,numbins,height,width,height_above_port_line);
        translate([0,0,-cut_point + -s/2])
        cube([s,s,s],center = true);         
    }
}
module BinsCylindricalCap(depth,numbins,height,width,height_above_port_line) {
    bin_radius = width/2;
    cut_point = (bin_radius)*cos(bin_cutaway_angle);
    s = 1000;
    difference() {
        Bins(depth,numbins,height,width,height_above_port_line);
        translate([0,0,-cut_point + s/2])
        cube([s,s,s],center = true);         
    }
}


module BinCap(depth,numbins,height,width,height_above_port_line) {
    b = bin_wall_thickness_mm*2;
    difference() {
        cube([width+b,depth+b,3],center=true);
        translate([0,0,bin_wall_thickness_mm])
        cube([width,depth,3],center=true);
    }
}

module Screws(num_screws,num_bins,depth) {
    d = (num_screws-1)*screw_center_separation_mm;
    union() {
        for (i = [0:num_screws-1]) {
            x =  -d/2+ i * screw_center_separation_mm;
            translate([x,0,0])
            CorkscrewWithSlit(depth,num_bins);
        }
    }
}
module ScrewsKnife(num_screws,num_bins,depth) {

    d = (num_screws-1)*screw_center_separation_mm;
    // Warning!  This is a bug; I should do the math
    // better. If we are doing 1 revolution because of 
    // printing thin walls, then we have to rotate here...
    // which shows that my math is incomplete...
    theta = (number_of_revolutions_in_bin == 1) ? 180 : 0;
    echo(" ================= theta");
    echo(theta);
    echo(number_of_revolutions_in_bin);
    rotate([0,0,theta])
    union() {
        // now we must cut the ports
        for (i = [0:num_screws-1]) {
             x =  -d/2+ i * screw_center_separation_mm;
             translate([x,0,0])
             CorkscrewWithoutVoidExcess(depth,filter_twist_degrees);
        }  
     }   
}

module BarbPort() {
    translate([0, 0, 0])
    rotate([0,0,90])
    rotate([0,90,0])
    Barb(barb_input_diameter,barb_output_diameter);
}


module BinsWithScrew(nums_screws,num_bins) {
    d = (num_screws-1)*screw_center_separation_mm;
    difference() {
        BinsCutaway(filter_height_mm,num_bins,bin_height_z_mm,bin_breadth_x_mm, screw_center_separation_mm);
        ScrewsKnife(num_screws,num_bins,filter_height_mm);
    }
    
    for (i = [0:num_screws-1]) {
        x =  -d/2 + i * screw_center_separation_mm;
        translate([x,0,0])
        CorkscrewWithSlit(filter_height_mm,num_bins);
    }
      
    if (USE_BARBS) {
        // Outlet
        translate([0,filter_height_mm/2,0])
        translate([screw_OD_mm,0,0])
        BarbPort();
        
        // Inlet
        translate([0,-filter_height_mm/2,0])
        translate([screw_OD_mm,0,0])
        rotate([0,0,180])
        BarbPort();
    }
}

// This is a simple tapered fitting with
// a female side and a male side, appropriately tapered.
// It also has an "internal stop", to make the male part
// fit into it will not be inserted so far as to cover up
// the pressure barb.
module PressureAndFilterFitting() {
    stage_length = 60;
    // this is the male OD and the female ID
    basic_radius = bin_out_radius;
    attachment_wall_width = 3;
    stop_wall_width = 1;
    inner_most_radius = basic_radius - attachment_wall_width;
    slop = 2;
    taper_radius = 2;
    
    difference() {
        // Now add barb for measuring pressure...
        union() {
            translate([basic_radius-5,0,-5])
            rotate([0,-90,0])       
            barb(hose_od, hose_id, swell, wall_thickness, barbs, barb_length, shell, bore, ezprint);
            // This intersection adds a taper...
            intersection() {
                cylinder(h = stage_length,r1 = basic_radius - taper_radius, r2 = basic_radius+taper_radius,center = true);
            // This is the main cylinder
                difference() {
                    cylinder(h = (stage_length),r = basic_radius+1,center = true);
            // This it the inside knife, with an internal stop
                    union() {
                        // female part
                        translate([0,0,(stage_length+slop)/4])
                        cylinder(h = (stage_length+slop)/2,
                        r1 = inner_most_radius, 
                        r2 = inner_most_radius+taper_radius,
                        center = true);
                        // male part
                        translate([0,0,-(stage_length+slop)/4])
                        cylinder(h = (stage_length+slop)/2,r = inner_most_radius-stop_wall_width,center = true);
                    }
                }
            }
        }
        // now drill out the pressure sensor barb
        translate([basic_radius+4,0,-5])
        rotate([0,-90,0])
        cylinder(h=barb_length*barbs+20,r=(hose_id-wall_thickness)/2,center=true);   
    }

}

if (USE_BINCAP) {
    translate([0,0,-2])
    BinsCylindricalCap(filter_height_mm,num_bins,bin_height_z_mm,bin_breadth_x_mm, screw_center_separation_mm);
}
    
    
    
if (USE_FULL_BINS) {

    difference() {
        BinsWithScrew(num_screws,num_bins);
        if (USE_KNIFE_THRU_SCREWS) {
            translate([0,0,-50])
            cube([200,200,100],center = true);
        }
        if (USE_KNIFE_LOW) {
            translate([0,0,-50+-10])
            cube([100,100,100],center = true);
        }
        if (USE_KNIFE_SIDE) {
            translate([50+5,0,0])
            cube([100,100,100],center = true);
            translate([-(50+5),0,0])
            cube([100,100,100],center = true);
        }   
        if (USE_KNIFE_TOP_HALF) {
            translate([0,0,50])
            cube([100,100,100],center = true);
        }
    }
       
}

if (USE_BINCAP) {
    translate([0,0,-2])
        BinsCylindricalCap(filter_height_mm,num_bins,bin_height_z_mm    ,bin_breadth_x_mm, screw_center_separation_mm);
}

if (USE_SCREW_ONLY) {
    Screws(num_screws,num_bins,filter_height_mm);
}
if (USE_SCREW_KNIFE) {
    ScrewsKnife(num_screws,num_bins,filter_height_mm);
}
if (USE_VOIDLESS_SCREW) {
    CorkscrewWithoutVoid(filter_height_mm,filter_twist_degrees);
}

if (USE_FITTING) {   
    difference() {
        translate([0,50,0])
        rotate([90,0,0])
        PressureAndFilterFitting();
        if (USE_FITTING_KNIFE ) {
            translate([0,0,-100])
            cube([200,200,200],center = true);
        }
    }
}

