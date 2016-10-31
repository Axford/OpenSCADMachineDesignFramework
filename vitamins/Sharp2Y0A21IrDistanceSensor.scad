/*
    Vitamin: Sharp 2Y0A21 Infrared Distance Sensor

    Local Frame:
*/

// Vitamin Catalogue
module Sharp2Y0A21_Catalogue() {
	Sharp2YA021();
}

// Connectors
Sharp2Y0A21_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];
Sharp2Y0A21_Con_Left			= [ [-37/2,0,0], [0,0,-1], 0, 0, 0];
Sharp2Y0A21_Con_Right			= [ [37/2,0,0], [0,0,-1], 0, 0, 0];

module Sharp2Y0A21() {

    vitamin("vitamins/Sharp2Y0A21IrDistanceSensor.scad", str("Sharp2Y0A21"), str("Sharp2Y0A21()")) {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(Sharp2Y0A21_Con_Def);
        }

        Sharp2Y0A21_Model();
    }
}

module Sharp2Y0A21_Model() {

    if (DebugConnectors) {
        connector(Sharp2Y0A21_Con_Left);
        connector(Sharp2Y0A21_Con_Right);
    }

	$fn=16;

	// Connector Lugs
	color(Grey20)
	for (i=[0, 1])
	mirror([i, 0, 0])
	translate([37/2, 0, 0]) {
		linear_extrude(1.5)
		difference() {
			union() {
				circle(d=7.5);
				translate([-4, -7.5/2, 0])
					square([4, 7.5]);

			}

			circle(d=3);
		}
		linear_extrude(5.5)
		difference() {
			translate([-4, -7.5/2, 0])
				square([2.2, 7.5]);

			circle(d=7.5);

		}
	}

	// Base 1
	color(Grey20)
	linear_extrude(7.1)
	difference() {
		square([29.5, 13], center=true);

		translate([0, 2.3/2 -13/2, 0])
			square([10.9, 2.3], center=true);
	}

	// Base 2
	color(Grey20)
	translate([0, 0, 7.1])
	render()
	difference() {
		linear_extrude(4.4)
			square([29.5, 8.3], center=true);

		translate([-7.5/2 + 29.5/2 -0.5, 0, 7.1])
		intersection() {
			sphere(d=10);
			translate([-1, 0, 0])
				cube([8, 7.2, 10], center=true);
		}
	}

	// left "eye"
	color(Grey20)
	translate([7.5/2 - 29.5/2 +0.5, 0, 7.1 + 4.4])
	union() {
		linear_extrude(2)
		difference() {
			square([7.5, 7.2], center=true);
			circle(d=5);
		}

		sphere(d=5);
	}


	// right "eye"
	color(Grey20)
	translate([-16.3/2 + 29.5/2 - 0.5, 0, 7.1 + 4.4])
	linear_extrude(2)
	difference() {
		square([16.3, 7.2], center=true);
		square([14.3, 5.2], center=true);
	}
	color(Grey20)
	translate([-7.5/2 + 29.5/2 -0.5, 0, 7.1 + 2])
		sphere(d=5);

	// Connector
	translate([0, -8.3/2 - 6/2, 3.2]) {
		color("green")
		linear_extrude(1.2)
			square([10.1, 6], center=true);

		translate([0, 0, 1.2])
		color("White")
		render()
		difference() {
			linear_extrude(5)
				square([7.7, 6], center=true);

			translate([0, -1, 0.5])
			linear_extrude(4)
				square([6.7, 5], center=true);
		}
	}
}
