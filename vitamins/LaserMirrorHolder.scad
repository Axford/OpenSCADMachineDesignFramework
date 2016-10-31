/*
    Vitamin: LaserMirrorHolder

    Local Frame:
*/


// Connectors

LaserMirrorHolder_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module LaserMirrorHolder(laserBeamLengths=[0,0], beamRot = 0) {

    vitamin("vitamins/LaserMirrorHolder.scad", "LaserMirrorHolder", "LaserMirrorHolder()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(LaserMirrorHolder_Con_Def);
        }

        laserMirror(laserBeamLengths, beamRot);
    }
}



laserMirror_width = 56;
laserMirror_depth = 9;
laserMirror_separation = 4.5;
laserMirror_boreRadius = 37/2;
laserMirror_centreFixingRadius = 6/2;   // for M6
laserMirror_outerFixingRadius = 4/2;  // for M4
laserMirror_outerFixingCentres = 14;
laserMirror_innerHolderThickness = 5;
laserMirror_fixingToMirror = laserMirror_depth/2 + laserMirror_separation + laserMirror_depth + 4;  // dist from fixing to mirror
laserMirror_fixingOffset = cos(45) * laserMirror_fixingToMirror;  // offset when mounting at 45 degrees


module laserMirrorHolder() {

    w = laserMirror_width;
    d = laserMirror_depth;
    r = laserMirror_boreRadius;
    cfr = laserMirror_centreFixingRadius;   // for M6
    ofr = laserMirror_outerFixingRadius;  // for M4
    ofc = laserMirror_outerFixingCentres;
    iht = laserMirror_innerHolderThickness;

    color(Grey20)
            difference() {

                roundedRect([w,w,d],5);

                translate([w/2,w/2,-1])
                    cylinder(r=r, h=d+2);
            }

    // inner holder
    color(Grey20)
        difference() {
            translate([w/2,w/2,d])
                cylinder(r=37/2, h=iht);

            translate([w/2,w/2,d-1])
                cylinder(r=23/2, h=iht+2);
        }

    // lens
    color([1,1,1,1])
        translate([w/2,w/2,d])
        cylinder(r=25/2, h=4);

}


module laserMirrorBase() {

    w = laserMirror_width;
    d = laserMirror_depth;
    r = laserMirror_boreRadius;
    cfr = laserMirror_centreFixingRadius;   // for M6
    ofr = laserMirror_outerFixingRadius;  // for M4
    ofc = laserMirror_outerFixingCentres;

    color(Grey20)
            difference() {

                roundedRect([w,w,d],5);

                translate([w/2,w/2,-1])
                    cylinder(r=r, h=d+2);

                // inner fixing
                translate([w/2,-1,d/2])
                    rotate([-90,0,0])
                    cylinder(r=cfr, h=w/2);

                // outer fixings
                for (i=[-1,1])
                    translate([w/2 + i*ofc/2,-1,d/2])
                    rotate([-90,0,0])
                    cylinder(r=ofr, h=w/2);

                // side fixings
                // inner
                translate([-1,w/2,d/2])
                    rotate([0,90,0])
                    cylinder(r=cfr, h=w/2);

                // outer
                for (i=[-1,1])
                    translate([-1,w/2 + i*ofc/2,d/2])
                    rotate([0,90,0])
                    cylinder(r=ofr, h=w/2);
            }

    // adjustment screws
    for (i=[0,1])
        translate([ 5 + i* (w - 10), 5 + i* (w - 10), 0])
        rotate([180,0,0]) {
            color("gold")
                translate([0,0,-d-laserMirror_separation])
                cylinder(r=5/2, h=17 + d + laserMirror_separation);

            color("gold")
                translate([0,0,4])
                cylinder(r=14/2, h=4);

            color(Grey20)
                translate([-6,-6,9])
                roundedRect([11.5,11.5,9],2);
        }

}



module laserMirror(laserBeamLengths=[0,0], beamRot = 0) {
    vitamin("laserMirror:");

    w = laserMirror_width;
    d = laserMirror_depth;

    rotate([90,0,0])
        translate([-w/2,0,-d/2]) {

            laserMirrorBase();

            translate([0,0,d + laserMirror_separation])
                laserMirrorHolder();

            // laser beams!
            for (i=[0,1])
                color([1,0,0,0.5])
                translate([w/2,w/2, 2*d + laserMirror_separation + 4])
                rotate([0,0,beamRot])
                rotate([0,45 - i*90,0])
                cylinder(r=1, h=laserBeamLengths[i]);
        }
}
