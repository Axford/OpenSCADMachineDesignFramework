/*
    Vitamin: DYS BLHeli 16A ESC

    Local Frame:
*/


// Connectors

DYS16AESC_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module DYS16AESC() {

    vitamin("vitamins/DYS16AESC.scad", "DYS BLHeli 16A ESC", "DYS16AESC()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(DYS16AESC_Con_Def);
        }

        color("red")
            cube([27,12,5]);
    }
}
