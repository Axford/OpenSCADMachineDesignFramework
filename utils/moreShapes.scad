// moreShapes library
// 2D and 3D utility shape functions

// some borrowed from nophead / Mendel90 utils.scad

// fudge
eta = 0.01;


/* *******************

	2D

******************* */

// circular segment - defined by a chord
// in XY plane
// chord begins at intersection of x+
// extends towards y+
// theta should be <= 180 degrees
module circularSegment(radius, theta) {
	intersection() {
		circle(radius);

		// chord hull
		polygon(
		[
			[radius, 0],
			[2*radius * cos(theta*0.25), 2*radius * sin(theta*0.1)],
			[2*radius * cos(theta*0.5), 2*radius * sin(theta*0.5)],
			[2*radius * cos(theta*0.75), 2*radius * sin(theta*0.9)],
			[radius * cos(theta), radius * sin(theta)]
		], 5);
	}
}

module hollowSquare(outer=[10,10], inner=[0,0], center=false) {
	// inner square is centred wrt outer square
	translate([center ? 0 : outer[0]/2, center ? outer[1]/2 : 0, 0])
		difference() {
			square(outer, center=true);
			square(inner, center=true);
		}
}

module chamferedSquare(size, chamfer, center=false) {
	hull() {
		translate([0,center?0:chamfer,0])
			square([size[0],size[1]-2*chamfer],center);

		translate([center?0:chamfer,0,0])
			square([size[0]-2*chamfer,size[1]],center);
	}
}

module roundedSquare(size, radius, center=false, shell=0) {
	x = size[0];
	y = size[1];

	translate([center?-x/2:0, center?-y/2:0, 0])
	difference() {
		hull() {
			translate([radius, radius, 0])
			circle(r=radius);

			translate([x - radius, radius, 0])
			circle(r=radius);

			translate([x - radius, y - radius, 0])
			circle(r=radius);

			translate([radius, y - radius, 0])
			circle(r=radius);
		}

		if (shell > 0) {
			hull() {
			translate([radius + shell, radius + shell, 0])
			circle(r=radius);

			translate([x - radius - shell, radius + shell, 0])
			circle(r=radius);

			translate([x - radius - shell, y - radius - shell, 0])
			circle(r=radius);

			translate([radius + shell, y - radius - shell, 0])
			circle(r=radius);
		}
		}
	}
}

module trapezoid(a,b,h,aOffset=0,center=false) {
	// lies in x/y plane
	// edges a,b are parallel to x axis
	// h is in direction of y axis
	// b is anchored at origin, extends along positive x axis
	// a is offset along y by h, extends along positive x axis
	// a if offset along x axis, from y axis, by aOffset
	// centering is relative to edge b

	translate([center?-b/2:0, center?-h/2:0, 0])
	polygon(points=[	[0,0],
					[aOffset,h],
					[aOffset + a, h],
					[b,0]]);
}

module rightTriangle(width,height,center=true) {
	polygon(points = [[0,0], [width, 0], [0, height]]);
}


// truss members forms a single diagonal element between two points
// the ends of the truss element are circular, of radius w/2
module trussProfile(p1, p2, w) {
	hull() {
		translate(p1)
			circle(r=w/2);
		translate(p2)
			circle(r=w/2);
	}
}


// chevron
// -------
// Width is along x, height is along y, points towards y+
// Centred along x, base on y=0

module chevron(width=10, height=6, thickness=3) {

	// Union the two halves together
	union() {
		// short loop to mirror the sides
		for (x=[0,1])
			// mirror the two sides
			mirror([x,0,0])
			// polygon to define the right (x+) side of the chevron shape
			polygon([
				[0, height],  			// tip of chevron
				[width/2, thickness],  	// top right corner
				[width/2, 0],			// bottom right corner
				[0, height-thickness]	// inside tip
			]);
	}
}


module sector(r, a, center = true) {
	intersection() {
			circle(r = r, center = true);
				polygon(points = [
					[0, 0],
					[2 * r * cos(0),  2 * r * sin(0)],
					[2 * r * cos(a * 0.2),  2 * r * sin(a * 0.2)],
					[2 * r * cos(a * 0.4),  2 * r * sin(a * 0.4)],
					[2 * r * cos(a * 0.6),  2 * r * sin(a * 0.6)],
					[2 * r * cos(a * 0.8),  2 * r * sin(a * 0.8)],
					[2 * r * cos(a), 2 * r * sin(a)],
				]);
		}
}

module donutSector(or,ir,a, center=true) {
	difference() {
		sector(or,a,center);

		circle(ir);
	}

}

module overhangFreeCircle(r, ang) {
	// produces a circle with no overhang ready for extrusion
	// overhang infill is along y axis

	x1 = r*cos(ang);
	y1 = r*sin(ang);
	x2 = tan(ang) * (r-y1);

	union() {
		circle(r);

		for (i=[0,1])
			mirror([0,i,0])
			polygon(points=[[0,0],[x1,y1],[x1-x2,r],[-x1+x2,r],[-x1,y1]]);
	}
}


/* *******************

	3D

******************* */


// rounded cylinder between two points
module line(start, end, r) {
	hull() {
		translate(start) sphere(r=r);
		translate(end) sphere(r=r);
	}
}


module roundedRect(size, radius, center=false, shell=0) {
	z = size[2];

	translate([0, 0, center?-z/2:0])
	    linear_extrude(height=z)
	    roundedSquare(size=size, radius=radius, center=center, shell=shell);
}

module roundedCube(size, radius, center=false, shell=0) {
	roundedRect(size, radius, center=center, shell=shell);
}

module roundedRectX(size, radius, center=false, shell=0) {
	// X-axis aligned roundedRect
	translate([0,0,center?0:size[2]]) rotate([0,90,0]) roundedRect([size[2],size[1],size[0]], radius, center, shell);
}

module roundedRectY(size, radius, center=false, shell=0) {
	// Y-axis aligned roundedRect
	translate([0,0,center?0:size[2]]) rotate([-90,0,0]) roundedRect([size[0],size[2],size[1]], radius, center, shell);
}

module allRoundedRect(size, radius, center=false) {
	// lazy implementation - must do better
	// runs VERY slow
	translate([center?-size[0]/2:0, center?-size[1]/2:0, center?-size[2]/2:0])
	hull() {
		for (x=[0,size[0]], y=[0,size[1]], z=[0,size[2]]) {
			translate([x,y,z]) sphere(r=radius);
		}
	}
}


module chamferedCube(size, chamfer, center=false, shell=0) {
	translate([0,0, center ? -size[2]/2 : 0])
		linear_extrude(size[2])
		chamferedSquare(size, chamfer, center=center, shell=shell);
}

module chamferedCubeX(size, chamfer, center=false, shell=0) {
	// X-axis aligned
	translate([0,0,center?0:size[2]]) rotate([0,90,0]) chamferedCube([size[2],size[1],size[0]], chamfer, center, shell);
}

module chamferedCubeY(size, chamfer, center=false, shell=0) {
	// Y-axis aligned
	translate([0,0,center?0:size[2]]) rotate([-90,0,0]) chamferedCube([size[0],size[2],size[1]], chamfer, center, shell);
}


// Extended rotational extrude, allows control of start/end angle

// Child 2D shape is used for the rotational extrusion
// Child 2D shape should lie in xy plane, centred on z axis
// Child y axis will be aligned to z axis in the extrusion

// NB: Internal render command is necessary to correclty display
// complex child objects (e.g. differences)

// r = Radius of rotational extrusion
// childH = height of child object (approx)
// childW = width of child object (approx)

// Example usage:

//   rotate_extrude_ext(r=50, childW=20, childH=20, start_angle=0, end_angle=180) {
//			difference() {
//				square([20,20],center=true);
//				translate([10,0,0]) circle(5);
//			}
//		}

module rotate_extrude_ext(r, childW, childH, convexity) {
	or = (r + childW/2) * sqrt(2) + 1;
	a0 = (4 * start_angle + 0 * end_angle) / 4;
	a1 = (3 * start_angle + 1 * end_angle) / 4;
	a2 = (2 * start_angle + 2 * end_angle) / 4;
	a3 = (1 * start_angle + 3 * end_angle) / 4;
	a4 = (0 * start_angle + 4 * end_angle) / 4;
	if(end_angle > start_angle)
		render()
		intersection() {
			rotate_extrude(convexity=convexity) translate([r,0,0]) children(0);

			translate([0,0,-childH/2 - 1])
			linear_extrude(height=childH+2)
				polygon([
					[0,0],
					[or * cos(a0), or * sin(a0)],
					[or * cos(a1), or * sin(a1)],
					[or * cos(a2), or * sin(a2)],
					[or * cos(a3), or * sin(a3)],
					[or * cos(a4), or * sin(a4)],
					[0,0]
			]);
	}
}


module torusSlice(r1, r2, start_angle, end_angle, convexity=10, r3=0, $fn=64) {
	difference() {
		rotate_extrude_ext(r=r1, childH=2*r2, childW=2*r2, start_angle=start_angle, end_angle=end_angle, convexity=convexity) difference() circle(r2, $fn=$fn/4);

		rotate_extrude(convexity) translate([r1,0,0]) circle(r3, $fn=$fn/4);
	}
}

module torus(r1, r2, $fn=64) {
	rotate_extrude()
		translate([r1,0,0])
		circle(r2, $fn=$fn/4);
}


module trapezoidPrism(a,b,h,aOffset,height,center=false) {
	translate([0,0, center?-height/2:0]) linear_extrude(height=height) trapezoid(a,b,h,aOffset,center);
}


// extruded rounded slot, or pill shape
module slot(h, r, l, center = true)
	linear_extrude(height = h, convexity = 6, center = center)
		hull() {
			translate([l/2,0,0])
				circle(r = r, center = true);
			translate([-l/2,0,0])
				circle(r = r, center = true);
		}



module fillet(r, h) {
	// ready to be unioned onto another part, eta fudge included
	// extends along x, y, z

	translate([r / 2, r / 2, 0])
		difference() {
			cube([r + eta, r + eta, h], center = true);
			translate([r/2, r/2, 0])
				cylinder(r = r, h = h + 1, center = true);
		}
}

module cylindricalFillet(cylR, filletR, outside=true) {
	// ready to be unioned onto another part, eta fudge included
	// extends along x, y, z

	if (outside) {
		difference() {
			translate([0,0,-eta])
				tube(cylR + filletR, cylR-eta, filletR + eta, center=false);
			translate([0,0,filletR])
				torus(cylR + filletR, filletR);
		}
	} else {
		difference() {
			translate([0,0,-eta])
				tube(cylR + eta, cylR-filletR, filletR + eta, center=false);
			translate([0,0,filletR])
				torus(cylR - filletR, filletR);
		}
	}
}

module right_triangle(width, height, h, center = true) {
	linear_extrude(height = h, center = center)
		rightTriangle(width,height,center=center);
}

module roundedRightTriangle(width, height, h, r=[1,1,1], center = true, $fn=12) {
	linear_extrude(height = h, center = center)
		hull() {
			translate([r[0],r[0],0]) circle(r[0]);
			translate([width-r[1],r[1],0]) circle(r[1]);
			translate([r[2],height-r[2],0]) circle(r[2]);
		}
}


//
// Cylinder with rounded ends
//
module roundedCylinder(r, h, r2, roundBothEnds=false)
{
	rotate_extrude()
		union() {
			square([r - r2, h]);
			translate([0,roundBothEnds?r2:0,0]) square([r, roundBothEnds? h-2*r2 : h - r2]);
			translate([r - r2, h - r2])
				circle(r = r2);
			if (roundBothEnds) {
				translate([r - r2, r2])
				circle(r = r2);
			}

		}
}

module chamferedCylinder(r, h, chamfer, center=false) {
	translate([0,0, center ? -h/2 : 0])
	rotate_extrude()
		hull() {
			square([r-chamfer, h]);
			translate([0, chamfer,0])
				square([r, h-2*chamfer]);
		}
}

module chamferedTube(or, ir, h, chamfer, center=false) {
	translate([0,0, center ? -h/2 : 0])
	rotate_extrude()
		difference() {
			hull() {
				square([or-chamfer, h]);
				translate([0, chamfer,0])
					square([or, h-2*chamfer]);
			}

			square([ir, h]);
		}
}

module sector3D(r, a, h, center = true) {
	linear_extrude(height = h, center = center)
		sector(r=r, a=a, center=center);
}

module tube(or, ir, h, center = true) {
	linear_extrude(height = h, center = center, convexity = 5)
		difference() {
			circle(or);
			circle(ir);
		}
}

module tubeSector(or1, ir1, a, h, center = true) {
	linear_extrude(height = h, center = center)
		difference() {
			sector(r=or1, a=a, center=center);
			circle(ir1);
		}

}

// tube that tapers
module conicalTube(or1,ir1,or2,ir2,h) {
	difference() {
		cylinder(r1=or1, r2=or2, h=h);

		translate([0,0,-eta])
			cylinder(r1=ir1, r2=ir2, h=h+2*eta);
	}
}

// supports span x axis
module minSupportBeam(size=[0,0,0], bridge=5, air=0, center=false) {
	w = size[0] > bridge ? (size[0] - bridge)/2 : 0;
	h = w > air ? air : w;

	union() {
		cube(size, center=center);

		// triangular supports
		for (i=[0,1])
			translate([i*size[0],0,eta])
			mirror([i,0,0]) {
				translate([w-h, 0, 0])
					rotate([-90,0,0])
					right_triangle(h, h, size[1], center=false);

				translate([0, 0, -h])
					cube([w-h+eta, size[1], h+eta]);

			}
	}
}

module minSupportBeamY(size=[0,0,0], bridge=5, air=0, center=false) {
	translate([size[0], 0, 0])
		rotate([0,0,90])
		minSupportBeam([size[1], size[0], size[2]], bridge, air, center=center);
}


// assumes p1,p2 lie in XY plane, shifted to p1[2]
module trussMember(p1,p2,w,t, cross=false) {
	translate([0,0,p1[2]])
		linear_extrude(t)
		trussProfile(p1,p2,w);

	if (cross)
		translate([0,0,p1[2]])
			linear_extrude(t)
			trussProfile([p2[0],p1[1]], [p1[0],p2[1]], w);
}


/* ****************************

	Visualisation Utilities

**************************** */

// Show cross section along axis (x)
// con defines the section plane
module section(con=[[0,0,0],[0,1,0],0,0,0], size=300, planeColor=[1,1,1])
{
    difference() {
        children();

        color(planeColor)
			attach(con, DefConUp)
        	translate([-size/2, -size/2, 0])
            cube(size);
    }
}

module arrangeShapesOnAxis(axis=[1,0,0], spacing=50) {
	for (i=[0:$children-1]) {
		translate([spacing * axis[0] *i,
					spacing * axis[1]*i,
					spacing * axis[2]*i]) children(i);
	}
}

module arrangeShapesOnGrid(xSpacing=50, ySpacing=50, cols=3, showLocalAxes=false) {
	// layout is cols, rows
	for (i=[0:$children-1]) {
		translate([(i - floor(i / cols)*cols) * xSpacing, floor(i / cols) * ySpacing, 0]) {
			children(i);

			if (showLocalAxes) {
				color("red") line([0,0,0], [xSpacing/2,0,0], 0.2);
				color("green") line([0,0,0], [0, ySpacing/2,0], 0.2);
				color("blue") line([0,0,0], [0, 0,xSpacing], 0.2);
			}
		}
	}
}
