/*
    Vitamin: Microswitch

    Local Frame:
*/


Microswitch_Width = 12.8;
Microswitch_Height = 6;
Microswitch_Depth = 5.8;
Microswitch_FixingCentres = 6.5;
Microswitch_FixingRadius = 2.5/2;

// Connectors

Microswitch_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];

Microswitch_Con_Fixing1 = [[(Microswitch_Width-Microswitch_FixingCentres)/2,Microswitch_FixingRadius,0],[0,0,1],0];   // mount one
Microswitch_Con_Fixing2 = [[(Microswitch_Width-Microswitch_FixingCentres)/2 + Microswitch_FixingCentres,Microswitch_FixingRadius,0],[0,0,1],0];    // mount two



module Microswitch() {

    vitamin("vitamins/Microswitch.scad", "Microswitch", "Microswitch()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(Microswitch_Con_Def);
            connector(Microswitch_Con_Fixing1);
            connector(Microswitch_Con_Fixing2);
        }

        Microswitch_Model();
    }
}



module Microswitch_Model() {
	w = Microswitch_Width;
	h = Microswitch_Height;
	d = Microswitch_Depth;
	con = [Microswitch_Con_Fixing1, Microswitch_Con_Fixing2];

	// body
	color([0.2,0.2,0.2,1])
		linear_extrude(d)
		difference() {
			square([w,h]);

			// mounting holes
			for (i=[0,1])
				translate([con[i][0][0], con[i][0][1],0])
				circle(Microswitch_FixingRadius);
		}

	// switch plate
	color("silver")
		translate([1,h,(d-3.4)/2])
		rotate([0,0,17])
		cube([12.6,0.3,3.4]);


	// connecting tabs
	for (i=[0:2])
		translate([i*(w-2.5)/2 + 0.5, -1.8, d/2])
		linear_extrude(0.3)
		difference() {
			square([1.6,1.6]);

			translate([0.8,0.8,0])
				circle(0.4);
		}

}
