/*

    Vitamin: GPS Module
    Modelled on 3DR uBlox GPS module

    Authors:
        Damian Axford

    Local Frame:
        Corner of RX, front is y+, right is x+

*/


// Global Vars
GPS_Width = 38;
GPS_Length = 38;
GPS_Height = 6;

// Connectors

module GPS_Fixings() {
    w = GPS_Width;
    d = GPS_Length;
    t = 1.7;

    fd = 3.3;  // fixing diameter
    fi = 3;  // fixing inset

    // fixings
    for (x=[0,1], y=[0,1])
        translate([fi + x*(w-2*fi), fi + y*(d-2*fi), 0])
        cylinder(r=fd/2, h=100, center=true, $fn=9);
}


module GPS() {
    w = GPS_Width;
    l = GPS_Length;
    h = GPS_Height;

    vitamin("vitamins/GPS.scad", "GPS Module", "GPS()") {
        view(t=[23,9,3],r=[34,2,22],d=320);
    }

    if (DebugCoordinateFrames) frame();
    if (DebugConnectors) {


    }

    // pcb
    color([0,0.4,0.2])
        difference() {
            cube([w,l,1.7]);

            GPS_Fixings();
        }

    // antenna
    color(Grey20)
        translate([w/2,l/2,3.7])
        cube([25,25,4], center=true);

    // cables


}
