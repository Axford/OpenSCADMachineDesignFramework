/*
    Vitamin: Turnigy Nano-Tech 120mAh 2S 25C Lipo Pack E-Flite Compatible

    Local Frame:
*/


// Connectors

TurnigyNanoTech120mAh2S25C_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module TurnigyNanoTech120mAh2S25C() {

    vitamin("vitamins/TurnigyNanoTech120mAh2S25C.scad", "Turnigy Nano-Tech 120mAh 2S 25C Lipo Pack E-Flite Compatible", "TurnigyNanoTech120mAh2S25C()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(TurnigyNanoTech120mAh2S25C_Con_Def);
        }

        color("green", 0.5)
            roundedRect([33,20, 7.5],2);
        // cables
        color("black")
            translate([33,2,2])
            rotate([0,0,30])
            cube([8,2,5]);
    }
}
