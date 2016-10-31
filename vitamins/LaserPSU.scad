/*
    Vitamin: Laser PSU

    Local Frame:
*/


// Connectors

LaserPSU_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module LaserPSU() {

    vitamin("vitamins/LaserPSU.scad", "Laser PSU", "LaserPSU()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(LaserPSU_Con_Def);
        }

        laserPowerSupply();
    }
}




laserPowerSupply_width = 169;
laserPowerSupply_height = 97;
laserPowerSupply_depth = 143;

module laserPowerSupply() {

    vitamin("laserPowerSupply:");

    //body
    color("orange")
        render()
        union() {
            // bottom
            cube([laserPowerSupply_width, laserPowerSupply_depth, 1]);

            //top
            translate([0,0,laserPowerSupply_height-1])
                cube([laserPowerSupply_width, laserPowerSupply_depth, 1]);

            //left
            cube([1, laserPowerSupply_depth, laserPowerSupply_height]);

            //front
            rotate([90,0,0])
                linear_extrude(1)
                difference() {
                    square([laserPowerSupply_width, laserPowerSupply_height]);

                    // grills
                    for (i=[0:6],j=[0,1])
                        translate([44 + i*39/7,30 + j*32,0])
                        square([3,30]);

                    for (i=[0:9])
                        translate([97 + i*54/10, 45,0])
                        square([3,30]);
                }

            // right
            translate([laserPowerSupply_width-1,0,0])
            rotate([90,0,90])
                linear_extrude(1)
                difference() {
                    square([laserPowerSupply_depth, laserPowerSupply_height]);

                    // grills
                    for (i=[0:7],j=[0,1])
                        translate([45 + i*50/8,20 + j*32,0])
                        square([3,30]);
                }

            // back
            translate([laserPowerSupply_width-1,laserPowerSupply_depth-1,0])
            rotate([90,0,180])
                linear_extrude(1)
                difference() {
                    square([laserPowerSupply_width, laserPowerSupply_height]);

                    // fan grill
                    translate([95,laserPowerSupply_height/2,0])
                        circle(77/2);
                }

        }

    // dark interior
    color(Grey20)
        translate([5,5,5])
        cube([laserPowerSupply_width-10, laserPowerSupply_depth-10, laserPowerSupply_height-10]);

    // connectors
    color("green")
        render()
        translate([12.5,-11,12])
        cube([31,11,15]);

    color("green")
        render()
        translate([136,-11,12])
        cube([15,11,15]);

    // test button
    color("red")
        render()
        translate([79,0,14])
        rotate([90,0,0])
        cylinder(r=3,h=3);

    // red lead
    translate([145,laserPowerSupply_depth,65])
        rotate([-90,0,0]) {
            color("white")
                cylinder(r=17/2, h=19);

            color("red")
                cylinder(r=4/2, h=80);

        }


    // blue lead
    translate([23,laserPowerSupply_depth,laserPowerSupply_height/2])
        rotate([-90,0,0])
            color("blue")
                cylinder(r=2/2, h=50);


    // mounting feet
    for (x=[0,1],y=[0,1])
        if (x>0 || y>0)
        color("orange")
        render()
        translate([23.5 + x*122, y*laserPowerSupply_depth, 0])
        rotate([0,0,(y-1)*180])
        translate([-7.5,0,0])
        difference() {
            cube([15,16,1]);

            translate([7.5,4,-1]) cylinder(r=8/2, h=3);

            translate([5.5,4,-1]) cube([4,9,3]);
        }
}
