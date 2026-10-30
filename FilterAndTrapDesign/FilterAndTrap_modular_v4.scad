/*
Public Invention - FilterAndTrap modular revision 4, experimental CAD.
CLOSE-COUPLED PAIR: reprint BOTH the swirl generator and the junction.
The Howard settling chamber and the two 22 mm male outlet cones are unchanged.

The complete swirl passage is now a CONSTANT 19.5 mm bore: no internal
connector neck, reduction, or recovery expansion before the skimmer.
The male cone is recessed over the final vane/hub region. Its tip is only
0.5 mm beyond the rounded hub tail. The skimmer starts 0.5 mm beyond that
seating plane: nominal hub-tip-to-skimmer distance = 1.0 mm.
A positive external shoulder fixes the nominal insertion depth. The existing
0.12 mm diametral print allowance is NOT a seal or a physical fit guarantee.

Dirty annulus = 20% of the GROSS 19.5 mm circle at the upstream skimmer lip.
The finite splitter rim counts in the gross area, but is not a flow opening.
This AREA fraction is NOT a FLOW fraction. Measure and adjust dirty flow.

The v3 bulged jacket and its small rounded core return are retained.
The two male outlets and female interface copy our existing nominal 22 mm
prototype cones. They are not gauge-certified ISO 5356-1 fittings.
NOT for clinical use; NOT pressure/vacuum rated. Test fit and leakage.

No external libraries. OpenSCAD 2021.01 compatible. All dimensions are mm.
Flow follows +Z; the dirty outlet points toward +X and +Z.
Both output STLs are complete parts, NOT the cutaway display.
*/
$fn = 72;

/* [View and export] */
part_mode = "assembled"; // [assembled,separated,junction only,swirl only,section,mating section,dirty air,skimmer section]
show_cutaway = false;
layout_gap = 15;

/* [Skimmer area definition] */
// The skimmer and the COMPLETE swirl passage share the male connector bore.
// Edit connector_male_bore below; jacket_id and bore_d follow automatically.
dirty_area_fraction = 0.20; // [0.05:0.01:0.40]
skimmer_tip_wall = 0.6;
core_wall = 2;
skimmer_length = 12;
skimmer_setback = 0.5; // lip beyond nominal fully inserted male tip; not zero-contact
jacket_wall = 1.5;

/* [New bulged jacket path] */
expansion_length = 16; // after lip; retains v3 expansion length, shifted upstream
collector_radial_gap = 3.8; // gap at the end of the axisymmetric expansion
outward_turn = 75;         // first turn bows beyond final outlet direction
bend_angle = 45;           // final dirty outlet direction
outward_radius = 32;
return_radius = 28;
dirty_neck_length = 20;
dirty_return_bore = 24;
core_return_radius = 1.0;   // radius removes the original sharp fluid cusp
round_core_return = true;
clean_outlet_z_extra = 16;
clean_neck_length = 10;

/* [Existing nominal 22 mm prototype connectors - UNCHANGED] */
connector_length = 22;
connector_male_base_od = 22.55;
connector_male_tip_od = connector_male_base_od-connector_length/40;
connector_male_bore = 19.5;
connector_female_clearance_d = 0.12;
connector_female_od = 27;
connector_shoulder_len = 1.5;
// There is deliberately NO bore transition before the skimmer.

/* [Close-coupled vane generator] */
hub_tip_to_male_tip = 0.5; // hub tail ends just before the male opening
swirl_wall = 1.5;         // body wall; bore stays identical through the male cone
shoulder_length = 2;      // external positive insertion stop, not an air obstruction
shoulder_od = 27;         // matches female socket exterior
shoulder_ramp_length = 3; // external approach to stop collar
vane_count = 3;
vane_thickness = 1.5;
hub_d = 5;
vane_start = 8;
vane_length = 82;
helix_pitch = 75;
round_hub_ends = true;
hub_nose_length = 7;
hub_tail_length = 12;
hub_profile_steps = 40;

/* [Mesh quality] */
path_steps = 30;
section_sides = 72;
expansion_steps = 20;
eps = 0.05;
join_overlap = 0.35;

/* [Hidden] */
jacket_id = connector_male_bore;
expansion_end_z = skimmer_setback+expansion_length;
vane_end_z = vane_start+vane_length;
hub_end_z = vane_end_z+(round_hub_ends ? hub_tail_length : 0);
swirl_tip_z = hub_end_z+hub_tip_to_male_tip;
// The male cone now overlaps the final vanes/tail instead of being added after them.
cone_base_z = swirl_tip_z-connector_length;
tube_length = cone_base_z; // straight outer body length, NOT total flow-path length
assembled_junction_z = swirl_tip_z;
function clamp01(x) = max(0,min(1,x));
function smoothstep(x) = let(t=clamp01(x)) t*t*(3-2*t);
function lerp(a,b,t) = a+(b-a)*t;
// The requested fraction is applied at the EXTERNAL edge of the splitter lip.
skimmer_lip_od = jacket_id*sqrt(1-dirty_area_fraction);
core_id = skimmer_lip_od-2*skimmer_tip_wall;
core_od = core_id+2*core_wall;
core_r = core_od/2;
skimmer_gap = (jacket_id-skimmer_lip_od)/2;
skimmer_z = skimmer_setback;
collector_r = core_r+collector_radial_gap;
core_connector_base_z = dirty_base()[2]+clean_outlet_z_extra;
clean_neck_start_z = core_connector_base_z-clean_neck_length;
jacket_od = jacket_id+2*jacket_wall;
tube_od = jacket_id+2*swirl_wall;
tube_wall = swirl_wall;
bore_d = jacket_id;
vane_twist = 360*vane_length/helix_pitch;
vane_slices = max(72,ceil(abs(vane_twist)/4));
area_total = PI*jacket_id*jacket_id/4;
area_dirty = area_total*dirty_area_fraction;
area_clean = PI*core_id*core_id/4;
area_rim = area_total-area_dirty-area_clean;

assert(dirty_area_fraction>0 && dirty_area_fraction<0.5);
assert(core_id>0 && skimmer_tip_wall>0 && core_wall>skimmer_tip_wall);
assert(skimmer_setback>=0.3,
       "Leave at least 0.3 mm between connector tip plane and skimmer lip");
assert(hub_tip_to_male_tip>=0.3,
       "Leave positive clearance between hub tail and connector tip plane");
assert(expansion_end_z>skimmer_z+skimmer_length);
assert(outward_turn>bend_angle && outward_turn<90);
assert(outward_radius>collector_r+2*jacket_wall);
assert(return_radius>collector_r+2*jacket_wall);
assert(collector_radial_gap>2*core_return_radius+0.5);
assert(core_return_radius>0 && dirty_neck_length>5);
assert(connector_male_tip_od-connector_male_bore>=2.4);
assert(connector_female_od>connector_male_base_od+connector_female_clearance_d+2);
assert(clean_neck_start_z>expansion_end_z+outward_radius*sin(outward_turn)+5);
assert(hub_nose_length>0 && hub_nose_length<vane_start);
assert(vane_end_z<swirl_tip_z && hub_end_z<swirl_tip_z);
assert(bore_d>hub_d+2 && vane_count>=1 && helix_pitch>0);
assert(cone_base_z>vane_start+shoulder_length+shoulder_ramp_length);
assert(swirl_wall>=1.2 && shoulder_length>=1);
assert(shoulder_od>connector_male_base_od+connector_female_clearance_d+1);
assert(shoulder_od>=tube_od);
assert(connector_male_tip_od/2 >
       sqrt(pow(bore_d/2+join_overlap,2)+pow(vane_thickness/2,2)),
       "Vanes must stay inside the smallest outside cone diameter");
assert(section_sides>=32);
assert(core_r+2*core_return_radius+eps<collector_r);
assert(!round_core_return || outward_turn >
       acos((outward_radius-core_r-2*core_return_radius-eps)/
            (outward_radius+collector_r))+1,
       "Increase outward_turn: rounded return must lie inside the first arc");

echo("Skimmer total / dirty / clean / rim areas mm2",
     [area_total,area_dirty,area_clean,area_rim]);
echo("Skimmer lip OD / radial dirty gap / clean ID mm",
     [skimmer_lip_od,skimmer_gap,core_id]);
echo("Annulus / full inlet area; annulus / combined open area",
     [area_dirty/area_total,area_dirty/(area_dirty+area_clean)]);
echo("Dirty male base XYZ and direction degrees",dirty_base(),bend_angle);
echo("Clean male base Z",core_connector_base_z);
echo("Constant swirl bore / male base / male tip Z",
     [bore_d,cone_base_z,swirl_tip_z]);
echo("Hub tail / skimmer GLOBAL Z",[hub_end_z,swirl_tip_z+skimmer_z]);
echo("Hub-tip-to-skimmer / vane-end-to-skimmer gaps mm",
     [swirl_tip_z+skimmer_z-hub_end_z,swirl_tip_z+skimmer_z-vane_end_z]);

// ----- The deliberately bowed, compound-curve jacket CENTERLINE -----
// Circular arcs share position and tangent. First: axial -> 75 degrees.
// Second: 75 -> 45 degrees. The outer wall also expands before the bend.
function outward_point(a) =
  [outward_radius*(1-cos(a)),0,expansion_end_z+outward_radius*sin(a)];
function return_point(a) = let(p=outward_point(outward_turn))
  [p[0]+return_radius*(cos(a)-cos(outward_turn)),0,
   p[2]+return_radius*(sin(outward_turn)-sin(a))];
function dirty_tangent() = [sin(bend_angle),0,cos(bend_angle)];
function dirty_base() = return_point(bend_angle)+dirty_neck_length*dirty_tangent();
function core_outer_r(z) = skimmer_lip_od/2+(core_wall-skimmer_tip_wall)*
  smoothstep((z-skimmer_z)/skimmer_length);
function expanding_r(z) = core_outer_r(z)+
  lerp(skimmer_gap,collector_radial_gap,
       smoothstep((z-skimmer_z)/(expansion_end_z-skimmer_z)));
// Each ring = [x,y,z, tangent angle from +Z, inner radius].
function inlet_rings() = concat(
  [[0,0,-eps,0,jacket_id/2],[0,0,skimmer_z,0,jacket_id/2]],
  [for(k=[1:expansion_steps]) let(z=lerp(skimmer_z,expansion_end_z,k/expansion_steps))
    [0,0,z,0,expanding_r(z)]]);
function main_rings() = concat(
  [for(k=[0:path_steps]) let(a=outward_turn*k/path_steps,p=outward_point(a))
    [p[0],p[1],p[2],a,collector_r]],
  [for(k=[1:path_steps]) let(t=k/path_steps,a=lerp(outward_turn,bend_angle,t),p=return_point(a))
    [p[0],p[1],p[2],a,lerp(collector_r,dirty_return_bore/2,smoothstep(t))]],
  [for(k=[1:12]) let(t=k/12,p=return_point(bend_angle)+dirty_tangent()*dirty_neck_length*t)
    [p[0],p[1],p[2],bend_angle,
     lerp(dirty_return_bore/2,connector_male_bore/2,smoothstep(t))]]);
function all_rings()=concat(inlet_rings(),[for(i=[1:len(main_rings())-1])main_rings()[i]]);
function ring_vertex(s,j,n,delta) = let(a=360*j/n,r=s[4]+delta)
  [s[0]+r*cos(s[3])*cos(a),s[1]+r*sin(a),s[2]-r*sin(s[3])*cos(a)];
function idx(i,j,n)=i*n+(j%n);
module ring_sweep(rings,delta=0,n=section_sides) {
  m=len(rings);
  polyhedron(points=concat(
      [for(s=rings,j=[0:n-1]) ring_vertex(s,j,n,delta)],
      [[rings[0][0],rings[0][1],rings[0][2]]],
      [[rings[m-1][0],rings[m-1][1],rings[m-1][2]]]),
    faces=concat(
      [for(i=[0:m-2],j=[0:n-1]) [idx(i,j,n),idx(i,j+1,n),idx(i+1,j+1,n)]],
      [for(i=[0:m-2],j=[0:n-1]) [idx(i,j,n),idx(i+1,j+1,n),idx(i+1,j,n)]],
      [for(j=[0:n-1]) [m*n,idx(0,j+1,n),idx(0,j,n)]],
      [for(j=[0:n-1]) [m*n+1,idx(m-1,j,n),idx(m-1,j+1,n)]]),convexity=20);
}
module jacket_envelope() { ring_sweep(all_rings(),jacket_wall); }
module jacket_air_envelope() { ring_sweep(all_rings()); }

// ----- Core envelope: thin leading lip thickens OUTWARD inside expanded jacket -----
module core_outer() {
  rotate_extrude($fn=section_sides,convexity=10)
    polygon(concat([[0,skimmer_z]],
      [for(k=[0:expansion_steps]) let(z=skimmer_z+skimmer_length*k/expansion_steps)
        [core_outer_r(z),z]],
      [[core_r,clean_neck_start_z],[connector_male_base_od/2,core_connector_base_z+eps],
       [0,core_connector_base_z+eps]]));
}
module core_air() {
  translate([0,0,skimmer_z-eps])
    cylinder(d=core_id,h=clean_neck_start_z-skimmer_z+2*eps);
  translate([0,0,clean_neck_start_z-eps])
    cylinder(d1=core_id,d2=connector_male_bore,h=clean_neck_length+2*eps);
  translate([0,0,core_connector_base_z-eps])
    cylinder(d=connector_male_bore,h=connector_length+2*eps);
}
module raw_air() { difference() { jacket_air_envelope(); core_outer(); } }

// ----- Small, tangent inside radius at the RETURNING JACKET WALL -----
// The new path is the main change. A bulged circular sweep alone would only
// MOVE the sharp core/wall intersection. This local 1 mm wall radius removes
// that cusp as well. It is not the previous 33 mm-long upstream fairing.
//
// For the first circular bend, the ceiling in a core-centred radial plane is
// analytically available. A circle tangent to the vertical core and this
// ceiling gives a rounded return. Sampling its tangency avoids Minkowski's
// very expensive 3D decomposition and keeps this file self-contained.
return_phi_steps = section_sides;
return_radial_steps = 24;
return_tangent_samples = 120;
return_r0 = core_r-eps;
return_r1 = core_r+2*core_return_radius+eps;
return_cap_z = expansion_end_z+outward_radius*sin(outward_turn)+collector_r+jacket_wall+4;
function bend_ceiling(r,phi) = let(y=r*sin(phi),x=r*cos(phi),
  q=outward_radius+sqrt(max(0,collector_r*collector_r-y*y)))
  expansion_end_z+sqrt(max(0,q*q-(outward_radius-x)*(outward_radius-x)));
function tangency_option(k,phi) = let(
  r=core_r+2*core_return_radius*k/return_tangent_samples,
  dz=sqrt(max(0,core_return_radius*core_return_radius-
       pow(r-core_r-core_return_radius,2))))
  [bend_ceiling(r,phi)-dz,r];
function return_solution(phi) = let(
  options=[for(k=[0:return_tangent_samples]) tangency_option(k,phi)],
  heights=[for(v=options) v[0]],
  k=search(min(heights),heights)[0]) options[k];
return_solutions=[for(j=[0:return_phi_steps-1])return_solution(360*j/return_phi_steps)];
function return_floor(r,j) = let(phi=360*j/return_phi_steps,
  sol=return_solutions[j],zc=sol[0],rt=sol[1],rr=max(core_r,r))
  r<=core_r ? zc :
  r<rt ? zc+sqrt(max(0,core_return_radius*core_return_radius-
       pow(rr-core_r-core_return_radius,2))) : bend_ceiling(rr,phi);
function return_vertex(layer,i,j) = let(
  r=lerp(return_r0,return_r1,i/return_radial_steps),phi=360*j/return_phi_steps)
  [r*cos(phi),r*sin(phi),layer==0?return_floor(r,j):return_cap_z];
function ri(layer,i,j)=layer*(return_radial_steps+1)*return_phi_steps+
  i*return_phi_steps+(j%return_phi_steps);
module return_wall_radius_raw() {
  nr=return_radial_steps; np=return_phi_steps;
  polyhedron(
    points=[for(layer=[0:1],i=[0:nr],j=[0:np-1])return_vertex(layer,i,j)],
    faces=concat(
      [for(i=[0:nr-1],j=[0:np-1]) [ri(0,i,j),ri(0,i,j+1),ri(0,i+1,j+1)]],
      [for(i=[0:nr-1],j=[0:np-1]) [ri(0,i,j),ri(0,i+1,j+1),ri(0,i+1,j)]],
      [for(i=[0:nr-1],j=[0:np-1]) [ri(1,i,j),ri(1,i+1,j+1),ri(1,i,j+1)]],
      [for(i=[0:nr-1],j=[0:np-1]) [ri(1,i,j),ri(1,i+1,j),ri(1,i+1,j+1)]],
      [for(j=[0:np-1]) [ri(0,nr,j),ri(0,nr,j+1),ri(1,nr,j+1)]],
      [for(j=[0:np-1]) [ri(0,nr,j),ri(1,nr,j+1),ri(1,nr,j)]],
      [for(j=[0:np-1]) [ri(0,0,j),ri(1,0,j+1),ri(0,0,j+1)]],
      [for(j=[0:np-1]) [ri(0,0,j),ri(1,0,j),ri(1,0,j+1)]]),convexity=10);
}
module return_wall_radius() {
  intersection() { return_wall_radius_raw(); jacket_envelope(); }
}
module dirty_air() {
  difference() {
    raw_air();
    if(round_core_return) return_wall_radius();
  }
}

// ----- Existing female cone, now terminating at a BORE-MATCHED shoulder -----
// Socket mouth z=-22, inserted male tip z=0. The female cavity ends exactly
// at z=0; the air passage continues at 19.5 mm, with no conical recovery region.
// The mating male's exterior stop contacts the female mouth at full insertion.
module female_outer() {
  translate([0,0,-connector_length])
    cylinder(d=connector_female_od,h=connector_length+eps);
  translate([0,0,-eps]) cylinder(d1=connector_female_od,d2=jacket_od,
                                h=connector_shoulder_len+eps);
}
module female_air() {
  translate([0,0,-connector_length-eps])
    cylinder(d1=connector_male_base_od+connector_female_clearance_d+eps/40,
             d2=connector_male_tip_od+connector_female_clearance_d,
             h=connector_length+eps);
  // jacket_air_envelope starts at -eps and supplies the bore through z=0.
  // No cutter extends downstream far enough to remove the thin splitter lip.
}
module male_outer() {
  translate([0,0,-eps])
    cylinder(d1=connector_male_base_od+eps/40,d2=connector_male_tip_od,
             h=connector_length+eps);
}
module male_air() {
  translate([0,0,-2*eps]) cylinder(d=connector_male_bore,h=connector_length+3*eps);
}
module at_dirty_base() { translate(dirty_base()) rotate([0,bend_angle,0]) children(); }
module junction_native() {
  difference() {
    union() {
      jacket_envelope(); core_outer(); female_outer();
      at_dirty_base() male_outer();
      translate([0,0,core_connector_base_z]) male_outer();
    }
    union() {
      dirty_air(); female_air(); core_air(); at_dirty_base() male_air();
    }
  }
}
// Print orientation: female inlet mouth lies at z=0; clean outlet upright.
module junction() { translate([0,0,connector_length]) junction_native(); }

// ----- Constant-bore swirl generator with recessed male cone -----
module swirl_shell_and_male() {
  difference() {
    union() {
      cylinder(d=tube_od,h=cone_base_z);
      // Exterior insertion stop. Its flat downstream face is at the cone base.
      translate([0,0,cone_base_z-shoulder_length-shoulder_ramp_length])
        cylinder(d1=tube_od,d2=shoulder_od,h=shoulder_ramp_length+eps);
      translate([0,0,cone_base_z-shoulder_length])
        cylinder(d=shoulder_od,h=shoulder_length);
      translate([0,0,cone_base_z]) male_outer();
    }
    // One cylinder hollows the ENTIRE swirl body and cone. No internal neck.
    translate([0,0,-eps]) cylinder(d=bore_d,h=swirl_tip_z+2*eps);
  }
}
// Rotate an elliptical meridian about the hub axis. Both caps join the
// 5 mm diameter cylindrical hub tangentially, with NO abrupt flat end face.
// The ogive-like ends are rounded (ellipsoidal), rather than pointed cones.
// The hub remains a single connected solid throughout the vane section.
module rounded_hub() {
    r = hub_d/2;
    z_begin = vane_start;
    z_end = vane_start+vane_length;
    rotate_extrude($fn=72,convexity=10)
        polygon(points=concat(
            [[0,z_begin-hub_nose_length]],
            [for(k=[1:hub_profile_steps])
                let(t=k/hub_profile_steps)
                [r*sqrt(max(0,1-(1-t)*(1-t))),
                 z_begin-hub_nose_length + t*hub_nose_length]],
            [[r,z_end]],
            [for(k=[1:hub_profile_steps-1])
                let(t=k/hub_profile_steps)
                [r*sqrt(max(0,1-t*t)),
                 z_end+t*hub_tail_length]],
            [[0,z_end+hub_tail_length]]
        ));
}

module helical_deflector() {
    if(round_hub_ends)
        rounded_hub();
    else
        translate([0,0,vane_start]) cylinder(d=hub_d,h=vane_length);

    translate([0,0,vane_start]) {
        for(i=[0:vane_count-1]) {
            rotate([0,0,i*360/vane_count])
                linear_extrude(height=vane_length,twist=vane_twist,
                               slices=vane_slices,convexity=10)
                    translate([hub_d/2-join_overlap,-vane_thickness/2])
                        square([bore_d/2-hub_d/2+2*join_overlap,
                                vane_thickness]);
        }
    }
}
module swirl_generator() {
    union() { swirl_shell_and_male(); helical_deflector(); }
}


// Assembly positions preserve full male insertion, but do not imply a seal.
module selected_parts() {
  if(part_mode=="junction only" || part_mode=="section") junction();
  else if(part_mode=="swirl only") swirl_generator();
  else if(part_mode=="dirty air") translate([0,0,connector_length]) dirty_air();
  else if(part_mode=="skimmer section")
    translate([0,0,-skimmer_z]) intersection() {
      junction_native();
      translate([-50,-50,skimmer_z+0.001]) cube([100,100,0.2]);
    }
  else {
    swirl_generator();
    dz=assembled_junction_z+
       (part_mode=="separated" ? connector_length+layout_gap : 0);
    translate([0,0,dz]) junction_native();
  }
}
// A dedicated local section makes the 1 mm tail-to-lip clearance visible.
if(part_mode=="mating section")
  intersection() {
    difference() {
      selected_parts();
      translate([-200,-200,-200]) cube([600,200,800]);
    }
    translate([-18,-18,cone_base_z-7])
      cube([36,36,swirl_tip_z+skimmer_z+8-(cone_base_z-7)]);
  }
else if(show_cutaway || part_mode=="section")
  difference() {
    selected_parts();
    translate([-200,-200,-200]) cube([600,200,800]);
  }
else selected_parts();
