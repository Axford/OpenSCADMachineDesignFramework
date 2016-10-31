module DF13Connector(pins = 5)
{
	pitch = 1.25;
	l = 1.75 + pins * pitch;

	// Surround
	color("white") {
		cube([l, 3.3, 0.4]);

		linear_extrude(3.5) {
			difference() {
				square([l, 3.3]);

				translate([0.4, 0.4, 0])
					square([l - .8, 2.5]);
			}
		}
	}
	
	// Pins
	color(MetalColor)
		for (i = [0:pins - 1]) {
			translate([1.5 + i*pitch, 1.3, 0])
				cube([0.25, 0.6, 3.5]);
	}
}
