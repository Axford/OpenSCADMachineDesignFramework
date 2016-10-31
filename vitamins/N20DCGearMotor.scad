/*
    Vitamin: N20DCGearMotor

    Based on: https://sc01.alicdn.com/kf/HT1WTyBFIJbXXagOFbXz/200130534/HT1WTyBFIJbXXagOFbXz.jpg

    Local Frame:
        Centred on origin, shaft points up z+
*/


// Connectors

N20DCGearMotor_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 3];
N20DCGearMotor_Con_Shaft			= [ [0,0,2], [0,0,-1], 0, 0, 3];
N20DCGearMotor_Con_Fixing1				= [ [4.5,0,0], [0,0,-1], 0, 0, 0];
N20DCGearMotor_Con_Fixing2				= [ [-4.5,0,0], [0,0,-1], 0, 0, 0];

// Dims
N20DCGearMotor_Width = 12;
N20DCGearMotor_Height = 10;
N20DCGearMotor_Depth = 15+9;


module N20DCGearMotor(ShaftLength=10) {

    vitamin("vitamins/N20DCGearMotor.scad", "N20DCGearMotor", "N20DCGearMotor()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(N20DCGearMotor_Con_Def);
        }

        N20DCGearMotor_Model(ShaftLength=ShaftLength);
    }
}

module N20DCGearMotor_Model(ShaftLength) {
    w = N20DCGearMotor_Width;
    h = N20DCGearMotor_Height;
    d = N20DCGearMotor_Depth;

    color([0.9,0.8,0.3,1]) {
        // boss
        cylinder(r=4/2, h=0.8);

        // upper face plate
        difference() {
            translate([0,0,-0.4])
                roundedRect([w,h,0.8], 1, center=true);

            // mounting holes
            attach(N20DCGearMotor_Con_Fixing1, DefConUp)
                cylinder(r=1.6/2, h=50, center=true);
            attach(N20DCGearMotor_Con_Fixing2, DefConUp)
                cylinder(r=1.6/2, h=50, center=true);
        }

        // mid plate
        translate([0,0,-6+0.4])
            roundedRect([w,h,0.8], 1, center=true);

        // lower face plate
        translate([0,0,-9+0.4])
            roundedRect([w,h,0.8], 1, center=true);

        // standoffs
        for (i=[0,1])
            rotate([0,0,180*i])
            translate([4, 3, -9])
            cylinder(r=3/2, h=9);
    }

    color([0.8,0.8,0.8,1]) {

        // shaft
        difference() {
            cylinder(r=3/2, h=ShaftLength + 0.8);
            translate([-5, 1, 1.5])
                cube([10,10,100]);
        }


        // motor body
        translate([0,0,-d])
            intersection() {
                translate([-w/2, -h/2, 0]) cube([w,h,15]);
                cylinder(r=w/2, h=100, center=true);
            }

        // nubbin
        translate([0,0,-d-1])
            cylinder(r=5/2, h=1);

        // tabs
        for (i=[0,1])
            rotate([0,0,180*i])
            translate([w/2-2,0,-d-2])
            cube([0.5,2,2]);

    }
}
