/*
    Vitamin: DasMikro Ultra Mini 8CH PPM Receiver

    Local Frame:
*/


// Connectors

DasMikroReceiver_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module DasMikroReceiver() {

    vitamin("vitamins/DasMikroReceiver.scad", "DasMikro Ultra Mini 8CH PPM Receiver", "DasMikroReceiver()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(DasMikroReceiver_Con_Def);
        }

        color("blue")
            cube([22.5, 3, 10.5]);
    }
}
