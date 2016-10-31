

// twist lock fixing utility

20x20TwistLockFixingCon = [[0,0,0],[0,0,-1],0];

module 20x20TwistLockFixing(wall, screw=M4_cap_screw, screwLen = 8, rot=90) {
	translate([0,0,wall]) screw_and_washer(screw,screwLen);
	translate([0,0,0]) rotate([0,0,rot]) aluProTwistLockNut(BR_20x20_TwistLockNut);
}


M4SquareNut_thickness = 1.6;
M4SquareNut_width = 7;

module M4SquareNut() {

	color()
		render()
		linear_extrude(M4SquareNut_thickness)
		difference() {
			square([M4SquareNut_width,M4SquareNut_width],center=true);
			
			circle(screw_radius(M4_hex_screw));
		}
}

module 20x20SquareNutCarrier_stl() {

	w = 5.8;
	barbW = 0.3;
	
	lockOffset = -2.7;

	difference() {
		union() {
			// body of carrier
			translate([-w/2,-4,4.5])
				cube([w,11,5]);
			
			// add retaining barbs
			translate([-w/2,7,4.5])
				rotate([90,0,0])
				trapezoidPrism(w+2*barbW,w,4,-barbW,5);
		}
		
		// hollow for square nut
		translate([0,0,4.5 + 5 + 3*layers])
			rotate([0,0,45])
			cube([M4SquareNut_width,M4SquareNut_width,10],center=true);
			
		// flatten the end
		translate([-5,-6,4.5 + 3*layers])
			cube([10,5,10]);	
			
		//screw hole
		translate()
			cylinder(r=screw_radius(M4_hex_screw), h=100);
	}


	*color([0.7,0.7,0.7,1])
		translate([0,0,10-1.5-1.6])
		rotate([0,0,45])
		M4SquareNut();	
	
	*translate([0,-20,0])
	BR20x20WGBP([0,0,0], 
		            [0,100,0],
		            roll=0,
		            startGussets=[0,0,0,0], 
		            endGussets=[0,0,0,0]);
}

module 20x20SquareNutCarrierLock_stl() {

	w = 6;
	barbW = 0.3;
	
	lockOffset = -2.7;

	color([0.5,1,0.5,1])
		//render()
		difference() {
			union() {
				// body of carrier
				translate([-w/2,-7,4.5 + 3*layers])
					cube([w,11,4]);
			}
		
			// hollow for square nut
			translate([0,0,10-1.5-1.6 + 5 - 0.5])
				rotate([0,0,45])
				cube([M4SquareNut_width,M4SquareNut_width,10],center=true);
				
			// trim the ends to mesh with carrier
			for (i=[0,1])
				rotate([0,0,45 - i*90])
				translate([-3,M4SquareNut_width/2 -eta,4])
				cube([6,6,6]);
			
			// flatten the end
			*translate([-5,-6,10-1.5-1.6 - 0.5])
				cube([10,5,10]);	
			
			//screw hole
			translate()
				cylinder(r=screw_radius(M4_hex_screw), h=100);
		}

}


// composite connector that joins two parallel extrusions (mid-rail) to an orthogonal extrusion (end)
// sized for 20x20 extrusion
// mid-rail joints to be secured by t-nuts
// end joint to be secured by core screw
// further ancillary connection points are provided (e.g. for cladding panels)

// part origin is at intersection of rail centrelines
// with parallel extrusions lying in xz plane, end on extrusion in y plane
// gussets protruding along z+  (print orientation)
// endSide:  false= y-, true=y+

module 20x20TGusset_stl(width=100, coreSide=true, showScrews=false, showCoreScrew=false) {
	
	h1 = 20;  // web height
	
	gh = 20;  // gusset height
	gw = gh;  // gusset width
	
	screws = M4_cap_screw;
	core_screw = M6_selftap_screw;   // S6x16
	  
	sw = 5;  // slow width, between centres
	
	vitamin("20x20TGusset:");
	
	color(plastic_part_color())
		translate([0,0,-h1/2])
		render()
		union() {
		
			// base
			linear_extrude(default_wall) 
				difference() {
					square([width,20],center=true);
					
					// centre fixing
					circle(screw_clearance_radius(screws));
					
					// outer ancillary fixings
					if (width > 60)
						for (i=[0:2])
						translate([-20 + i*20,0,0])
						circle(screw_clearance_radius(screws));
				}
			
			// sides
			for (i=[0,1])
				mirror([i,0,0])
				translate([width/2,-10,0])
				rotate([0,-90,0])
				linear_extrude(default_wall)
				difference() {
					square([h1 + gh, 20]);
					
					// fixings
					translate([h1/2,10,0])
						circle(screw_clearance_radius(screws));
					
					translate([h1 + gh/2,10,0])
						circle(screw_clearance_radius(screws));
					
				}
			
		
			// front/back
			for (i=[0,1])
				mirror([0,i,0])
				translate([0,10,0])
				rotate([90,0,0])
				linear_extrude(default_wall)
				difference() {
					union() {
						// cross web
						translate([0,h1/2])
							square([width, h1], center=true);
			
						// gusset sides	
						for (i=[0,1])
							mirror([i,0,0])
							translate([-width/2,h1,0])
							polygon(points = [[0,0], [gw, 0], [default_wall, gh], [0, gh]]);
					}
			
					// centre slot			
					hull () {
						translate([-sw/2,h1/2,0])
							circle(screw_clearance_radius(core_screw));
						translate([sw/2,h1/2,0])
							circle(screw_clearance_radius(core_screw));
					}
		
					// ancillary fixings
					if (width > 60)
						for (i=[0,1])
						mirror([i,0,0])
						translate([-20,h1/2,0])
						circle(screw_clearance_radius(screws));
				}
		}
		
	if (showCoreScrew) 
		mirror([0,coreSide?0:1,0])
		translate([0,10 - default_wall,0])
		rotate([90,0,0])
		screw_and_washer(core_screw,16);
	
	if (showScrews)
		for (i=[0,1],j=[0,1])
		mirror([i,0,0]) {
			translate([width/2,0,j*(h1/2 + gh/2)])
				rotate([0,-90,0]) {
					translate([0,0,default_wall]) screw_and_washer(M4_cap_screw,8);
					translate([0,0,0]) rotate([0,0,90]) aluProTwistLockNut(BR_20x20_TwistLockNut);
				}
			
		}
	
}




module 20x20PrintedGusset_stl(screws=false,nibs=true) {
	// width, wall_thickness, slot width, slot height, slot offset from base, nib depth, nib width, label
	tg = [18, 2, 5, 7, 7.7, 1, 5.8, "BR20x20Gusset"];

	// sits on z=0
	// faces along y+ and z+	
	
	w = tg[0];
	t = tg[1];
	slotw = tg[2];
	sloth = tg[3];
	sloto = tg[4];
	nib = tg[5];
	nibw = tg[6];
	
	vitamin("20x20PrintedGusset");
	
	//color(grey80)
	color(plastic_part_color())  // colour as plastic for axCut build
	render()
	union() {
		// ends
		for (i=[0,1])
			mirror([0,-i,i])
			linear_extrude(t) {
				difference() {
					translate([-w/2,0,0]) square([w,w]);
					
					// slot for screw
					translate([(-slotw/2),sloto,0]) square([slotw,sloth]);
				}
			}
			
		// nibs
		if (nibs && !simplify)
			for (i=[0,1],j=[0,1])
			mirror([0,-i,i])
			rotate([0,-90,0])
			translate([j*(w-2*nib),0,-nibw/2])
			linear_extrude(nibw)
			polygon([[0,eta],
			         [2*nib,eta],
			         [nib,-nib],
			         [-nib,-nib]]);
		
		//sides
		for (i=[0,1])
			mirror([i,0,0])
			translate([w/2-t/2,t-eta,t-eta])
			rotate([0,-90,0])
			right_triangle(width=w-t, height=w-t, h=t, center = true);
	
		// tips
		if (!simplify)
			for (i=[0,1])
			mirror([0,-i,i])
			translate([w/2-t-eta,w-1,t-eta])
			rotate([0,-90,0])
			right_triangle(width=1, height=1, h=w-2*t+2*eta, center=false);
	}
	
	if (screws) {
		for (i=[0,1])
			mirror([0,-i,i]) {
				translate([0,12,t]) screw(M4_cap_screw,8);
				translate([0,12,0]) aluProTwistLockNut(BR_20x20_TwistLockNut);
			}
	}
}


// heavy duty 90 degree gusset to join 20x40 profile
// designed for the base of the axCut machine

module 20x40HeavyGusset_stl(screws=false) {
	// sits on z=0
	// faces along y+ and z+	
	w = 40;
	t = default_wall;
	slotw = screw_clearance_radius(M4_cap_screw) * 2;
	sloth = slotw * 1.5;
	nib = 1;   // depth of nib
	nibw = 5.8;  // width of nib
	
	vitamin("20x40HeavyGusset:");
	
	//color(grey80)
	color(plastic_part_color())  // colour as plastic for axCut build
	render()
	union() {
		// ends
		for (i=[0,1])
			mirror([0,-i,i])
			linear_extrude(t) {
				difference() {
					translate([-w/2,0,0]) square([w,w]);
					
					// slots for screw, 20mm centres
					for (j=[0,1],k=[0,1])
						translate([-10 + j*w/2 - slotw/2, 9 + k*20, 0]) 
						square([slotw,sloth]);
				}
			}
			
		// nibs - must add these at some point!
		if (!simplify)
			for (i=[0,1],j=[0,1],k=[0,1])
			mirror([0,-i,i])
			rotate([0,-90,0])
			translate([j*(w-2*nib),0,-10 + k*20 -nibw/2])
			linear_extrude(nibw)
			polygon([[0,0],
			         [2*nib,0],
			         [nib,-nib],
			         [-nib,-nib]]);
		
		//sides and inner rib
		for (i=[0:2])
			translate([-w/2+t/2 + i*(w-t)/2 ,t-eta,t-eta])
			rotate([0,-90,0])
			right_triangle(width=w-t, height=w-t, h=t, center = true);
	
		// tips
		if (!simplify)
			for (i=[0,1])
			mirror([0,-i,i])
			translate([w/2-t-eta,w-1,t-eta])
			rotate([0,-90,0])
			right_triangle(width=1, height=1, h=w-2*t+2*eta, center=false);
	}
	
	if (screws) {
		for (i=[0,1],j=[0,1],k=[0,1])
			mirror([0,-i,i]) {
				translate([-10 + k*20,12 + j*20,t]) screw(M4_cap_screw,8);
				translate([-10 + k*20,12 + j*20,0]) aluProTwistLockNut(BR_20x20_TwistLockNut);
			}
	}
}


// set embed to true to make this an embeddable part (within other parts)
// embed sets part origin to x=y=z=0

module 20x20SnapFitting_stl(embed=false) {
	
	w = 9;
	d=12;
	t = 2*perim;
	d2 = d - 4perim;
	d3 = d - 6*perim;
	splitW = 0.7;
	
	r = screw_clearance_radius(M4_hex_screw);
	
	if (!embed)
		stl("20x20SnapFitting");
	
	translate([0,0,embed?-10:0])
		//render()
		difference() {
			union() {
				// bridge
				if (!embed) 
					translate([-5.8/2,-d3/2-2,9])
					cube([5.8,d3+2,t]);
				
				// folds
				for (i=[0,1])
					mirror([i,0,0])
					translate([0,0,11])
					rotate([0,10,0])
					translate([0,-d3/2,-6])
					union() {
						translate([-0.5,0,0])
							cube([3,d3,5.5]);
					
						translate([1.8,0,2])
							cube([2,d3,2]);
					
						translate([2.5-eta,0,2])
							rotate([-90,0,0])
							right_triangle(1.3, 2 + eta, d3, center = false);
					}
	
			}
		
			// pilot hole
			translate([0,0,11])
				mirror([0,0,1])
				cylinder(r1=r, r2=0, h=7);
			
			// screw hole
			//cylinder(r=r/2, h=20);
			
			// central split line
			translate([-splitW/2,-d3/2-eta,0])
				cube([splitW, d3+2*eta, 10 + splitW/2]);
				
			// level the top
			if (!embed)
				translate([-50,-50,10])
				cube([100,100,100]);
		}
	
	// for dev
	*translate([0,-20,0])
	BR20x20WGBP([0,0,0], 
		            [0,100,0],
		            roll=0,
		            startGussets=[0,0,0,0], 
		            endGussets=[0,0,0,0]);
}


module 20x20DropInNut() {
	intersection() {
		linear_extrude(6)
			aluProTSlot(BR_20x20);
			
		%translate([0,0,3])
			rotate([0,90,0])
			cylinder(r=6,h=100);
	}
}