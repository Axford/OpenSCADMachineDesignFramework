/*
    Vitamin: TowerPro SG90 Driver

    Local Frame:
*/


// Connectors

TowerProSG90Driver_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module TowerProSG90Driver() {

    vitamin("vitamins/TowerProSG90Driver.scad", "TowerPro SG90 Driver", "TowerProSG90Driver()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(TowerProSG90Driver_Con_Def);
        }

        color("red")
            cube([10,3,10]);
    }
}
