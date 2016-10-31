// Pin Connectors for LogoBot
// Derived from Emmett Lalish Pin Connectors V3 : http://www.thingiverse.com/thing:33790
// Modified for @snhack LogoBot by Gyrobot
//
// Modules to call = pin(), pinpeg(), pintack(), pinhole()
//
// Parameters :
//
// h = Length or height of pin/hole.
// r = radius of pin body (Default = PinDiameter/2).
// lh = Height of lip.
// lt = Thickness of lip (Also adjusts slot width to allow legs to close).
// t = Pin tolerance.
// bh = Base Height (pintack only).
// br = Base Radius (pintack only).
// tight = Hole friction, set to false if you want a joint that spins easily (pinhole only)
// fixed = Hole Twist, set to true so pins can't spin (pinhole only)
//	Side = Orientates pins on their side for printing : true/false (not pinhole).

module pinhole(h=10, r=PinDiameter/2, lh=3, lt=1, t=0.3, tight=true, fixed=false) {
  
	intersection(){
	  union() {
	if (tight == true || fixed == true) {
	      pin_solid(h, r, lh, lt);
		  translate([0,0,-t/2])cylinder(h=h+t, r=r, $fn=30);
		} else {
		  pin_solid(h, r+t/2, lh, lt);
		  translate([0,0,-t/2])cylinder(h=h+t, r=r+t/2, $fn=30);
		}
        
	    // widen the entrance hole to make insertion easier
	    //translate([0, 0, -0.1]) cylinder(h=lh/3, r2=r, r1=r+(t/2)+(lt/2),$fn=30);
	  }
	  if (fixed == true) {
		translate([-r*2, -r*0.75, -1])cube([r*4, r*1.5, h+2]);
	  }
	}
}
module pin(h=10, r=PinDiameter/2, lh=3, lt=1, t=0.2, side=false) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness
  // side = set to true if you want it printed horizontally

  if (side) {
    pin_horizontal(h, r, lh, lt, t);
  } else {
    pin_vertical(h, r, lh, lt, t);
  }
}

module pintack(h=10, r=PinDiameter/2, lh=3, lt=1, t=0.2, bh=3, br=6, side=false) {
  // bh = base_height
  // br = base_radius
  
flip=(side==false) ? 1 : 0;

translate ([0,flip*(r*1.5-t)/2,0])
rotate ([flip*90,0,0])
  union() {
	pin(h, r, lh, lt, t, side=true);
	intersection(){
		translate([0, 0, r/1.5]) rotate([90,0,0]) cylinder(h=bh, r=br);
		translate([-br*2, -bh-1, 0])cube([br*4, bh+2, r*1.5-t]);
	}
  }
}

module pinpeg(h=20, r=PinDiameter/2, lh=3, lt=1, t=0.2, side=false) {
	flipy=(side==false) ? 1 : 0;
	flipz=(side==true) ? 1 : 0;
  union() {
		translate([0, flipz*-0.05, flipy*-0.05]) pin(h/2+0.1, r, lh, lt, t, side);
		translate([0, flipz*0.05, flipy*0.05]) rotate([0, flipy*180, flipz*180]) pin(h/2+0.1, r, lh, lt, t, side);
  }
}

// just call pin instead, I made this module because it was easier to do the rotation option this way
// since openscad complains of recursion if I did it all in one module
module pin_vertical(h=10, r=4, lh=3, lt=1, t=0.2) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness

  difference() {
    pin_solid(h, r-t/2, lh, lt);
    
    // center cut
    translate([-lt*3/2, -(r*2+lt*2)/2, h/5+lt*3/2]) cube([lt*3, r*2+lt*2, h]);
    //translate([0, 0, h/4]) cylinder(h=h+lh, r=r/2.5, $fn=20);
    // center curve
    translate([0, 0, h/5+lt*3/2]) rotate([90, 0, 0]) cylinder(h=r*2, r=lt*3/2, center=true, $fn=20);
  
    // side cuts
    translate([-r*2, -r-r*0.75+t/2, -1]) cube([r*4, r, h+2]);
    translate([-r*2, r*0.75-t/2, -1]) cube([r*4, r, h+2]);
  }
}

// call pin with side=true instead of this
module pin_horizontal(h=10, r=4, lh=3, lt=1, t=0.2) {
  // h = shaft height
  // r = shaft radius
  // lh = lip height
  // lt = lip thickness
  translate([0, 0, r*0.75-t/2]) rotate([-90, 0, 0]) pin_vertical(h, r, lh, lt, t);
}

// this is mainly to make the pinhole module easier
module pin_solid(h=10, r=4, lh=3, lt=1) {
  union() {
    // shaft
    cylinder(h=h-lh, r=r, $fn=30);
    // lip
    translate([0, 0, h-lh]) cylinder(h=lh*0.25, r1=r, r2=r+(lt/2), $fn=30);
    translate([0, 0, h-lh+lh*0.25]) cylinder(h=lh*0.25, r=r+(lt/2), $fn=30);    
    translate([0, 0, h-lh+lh*0.50]) cylinder(h=lh*0.50, r1=r+(lt/2), r2=r-(lt/2), $fn=30);    
  }
}