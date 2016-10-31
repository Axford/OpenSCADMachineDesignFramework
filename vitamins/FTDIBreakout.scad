/*

    Vitamin: FTDIBreakout
    Based on Sparkfun FTDI breakout

    Authors:
        Damian Axford

    Local Frame:
        Corner of pcb, nearest header

*/


// Connectors

// center of USB connector
FTDIBreakout_Con_USB = [[15.7/2, 23, 3.7], [0, -1, 0], 0,0,0];

// Ground pin on header
FTDIBreakout_Con_GroundPin = [[1.25, 0, -1.25], [0,-1,0], 0,0,0];


module SSOP28() {
    // centred

    w = 5.2;
    d = 10.07;
    h = 1.73;

    headerpitch = 0.1 * 25.4;

    pinw = (7.65 - w)/2;
    pind = 0.25;
    pins = 0.65;

    // chip
    color([0.2,0.2,0.2])
        translate([0,0,h/2])
        cube([w,d,h], center=true);

    // legs
    color([0.7,0.7,0.7])
        render()
        for (x=[0,1], y=[0:13])
        mirror([x,0,0])
        translate([w/2, -d/2 + 0.81 + y*pins - pind/2, 0 ])
        cube([pinw, pind, 0.2]);
}


module FTDIBreakout() {
    w = 15.7;
    d = 23;
    t = 1.7;

    vitamin("vitamins/FTDIBreakout.scad", "Sparkfun FTDI Breakout", "FTDIBreakout()") {
		view(d=300);
	}

    if (DebugCoordinateFrame) frame();
    if (DebugConnectors) {
        connector(FTDIBreakout_Con_USB);
        connector(FTDIBreakout_Con_GroundPin);
    }

    // PCB
    color([0.2,0.3,1])
        cube([w,d,t]);

    // USB
    color([0.7,0.7,0.7])
        translate([w/2 - 4, d-8.5, t])
        cube([8, 9, 4]);

    // Header (right angle, on underside)
    color("black")
        translate([0, 0, -2.6])
        cube([w, 8.5, 2.6]);

    // driver chip
    translate([w/2, 7, t])
        SSOP28();

}
