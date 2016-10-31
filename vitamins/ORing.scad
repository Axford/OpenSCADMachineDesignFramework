/*
    Vitamin: ORing


    Local Frame:
*/


// Connectors

oring_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];

module ORing(section=2, bore=10) {

    vitamin("vitamins/ORing.scad", str("O-Ring ",section,"x",bore), str("ORing(section=",section,", bore=",bore,")")) {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(oring_Con_Def);
        }

        color("Grey")
            torus(bore + section/2, section);
    }
}


// ORing visualised as wrapping round two shafts defined by connectors c1 and c2
// the connectors should define the bore of the two shafts (5th parameter)
module ORingOnShafts(section=2, bore=10, c1, c2) {
    vitamin("vitamins/ORing.scad", str("O-Ring ",section,"x",bore), str("ORing(section=",section,", bore=",bore,")")) {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(oring_Con_Def);
        }

        color("Grey")
            difference() {
                // outer rings
                hull() {
                    attach(c1, DefConUp)
                        torus(connector_bore(c1)/2 + section/2, section/2);
                    attach(c2, DefConUp)
                        torus(connector_bore(c2)/2 + section/2, section/2);
                }

                // inner rings
                hull() {
                    attach(c1, DefConUp)
                        cylinder(r=connector_bore(c1)/2, h=2*section, center=true);
                    attach(c2, DefConUp)
                        cylinder(r=connector_bore(c2)/2, h=2*section, center=true);
                }
            }

    }
}
