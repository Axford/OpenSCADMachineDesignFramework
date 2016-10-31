/*
    Vitamin: Ziptie
    Common Zipties, modelled as if tied around a cylinder

    Attribution:
    Based on the Zipties.scad file from the Mendel90 project, GPL v2 by:
        nop.head@gmail.com
        hydraraptor.blogspot.com

    Usage:
        Ziptie(Ziptie_2p5, r=12, l=100)

    Local Frame:
        Centred on origin
        Wrapped around the z-axis
        Latch is at Y-
*/


// Types
// -----

// Getters
function Ziptie_TypeSuffix(t)  = t[0];
function Ziptie_Width(t)       = t[1];
function Ziptie_Thickness(t)   = t[2];
function Ziptie_LatchSize(t)   = t[3];

// Type table
//            ts,      w,   t, LatchSize
Ziptie_2p5 = ["2p5",   2.5, 1, [4.7, 4.25, 3]];
Ziptie_3p6 = ["3p6",   3.6, 1, [4.7, 4.25, 3]];  //todo: finish these!
Ziptie_4p8 = ["4p8",   4.8, 1, [4.7, 4.25, 3]];
Ziptie_7p6 = ["7p6",   7.6, 1, [4.7, 4.25, 3]];



// Connectors

Ziptie_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module Ziptie(type=Ziptie_2p5, r=12, l=100, clr=Grey20, trim=true) {
    ts = Ziptie_TypeSuffix(type);
    w = Ziptie_Width(type);

    vitamin("vitamins/Ziptie.scad",
            str(w,"mm x ",l,"mm Ziptie"),
            str("Ziptie(Ziptie_",ts,", r=12, l=",l,", trim=false)")) {
        view(r=[60,0,33], d=250);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(Ziptie_Con_Def);
        }

        Ziptie_Model(type, r, l, clr, trim);
    }
}


module Ziptie_Model(type, r, l=100, clr=Grey20, trim=true)
{
    latch = Ziptie_LatchSize(type);
    length = ceil(2 * PI * r + latch[2] + 1);
    len = length <= l ? l : length;
    w = Ziptie_Width(type);
    t = Ziptie_Thickness(type);

    angle = (r > latch[0] / 2) ? asin((latch[0] / 2) / r) - asin(Ziptie_Thickness(type) / latch[0]) : 0;
    color(clr)
        render(convexity = 5)
        union() {
            // wrap
            tube(ir = r, or = r + Ziptie_Thickness(type), h = Ziptie_Width(type));

            // latch
            translate([0, -r, - latch[1] / 2])
                rotate([90, 0, angle]) {
                    union() {
                        // latch body
                        cube(latch);
                        // stub
                        translate([latch[0] / 2, latch[1] / 2, (latch[2] + 1) / 2])
                            cube([Ziptie_Thickness(type), Ziptie_Width(type), latch[2] + 1], center = true);
                    }
                }

            // left-over
            if (!trim && l > length) {
                translate([latch[0] / 2, -r - latch[1] / 2, -w/2])
                    rotate([0,0,180])
                    chamferedCubeX([t, l-length, w], w/4);
            }
        }
}
