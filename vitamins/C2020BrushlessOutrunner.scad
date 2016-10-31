/*
    Vitamin: C2020 Brushless Outrunner

    Local Frame:
*/


// Connectors

C2020BrushlessOutrunner_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module C2020BrushlessOutrunner() {

    vitamin("vitamins/C2020BrushlessOutrunner.scad", "C2020 Micro Brushless Outrunner 3500kv 11g", "C2020BrushlessOutrunner()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(C2020BrushlessOutrunner_Con_Def);
        }

        C2020BrushlessOutrunner_Model();
    }
}

module C2020BrushlessOutrunner_Model() {
    color("orange") {
        // base plate - triangular ish thing
        union() {
            cylinder(r=20.2/2, h=2);

            // grind off one of the feet
            for (i=[0:1])
                rotate([0,0,i*120 + 60])
                hull() {
                    cylinder(r=2, h=2);
                    translate([11,0,0])
                        cylinder(r=3, h=2);
                }
        }


        // midriff
        hull() {
            translate([0,0,5.5]) cylinder(r=20.2/2, h=6);

            cylinder(r=20.2/2-5, h=14);
        }

        // prop holder - grind off?
        translate([0,0,14])
            cylinder(r=8/2, h=5);

        // lower circlip
        translate([0,0,-2])
            cylinder(r=3/2, h=2);
    }

    color("grey") {
        //shaft - grind shorter
        translate([0,0,-2.5])
            cylinder(r=2/2, h=23);
    }

    color("black") {
        // wires
        translate([7,-3/2,2])
            cube([8,3,1.5]);
    }
}
