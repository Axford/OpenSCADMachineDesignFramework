/*
    Vitamin: Stepper Motor
    Models of common NEMA stepper motors

    Based on the stepper-motors.scad file from the Mendel90 project, GPL v2 by:
        nop.head@gmail.com
        hydraraptor.blogspot.com

    Local Frame:
        Centred on origin, mounting face of motor at Z=0
        Shaft points along Z+
        Wires stickout Y+
*/


// Types
// -----

// Getters
function StepperMotor_Width(t)        = t[0];
function StepperMotor_Length(t)       = t[1];
function StepperMotor_CornerRadius(t) = t[2];
function StepperMotor_BodyRadius(t)   = t[3];
function StepperMotor_BossRadius(t)   = t[4];
function StepperMotor_BossDepth(t)    = t[5];
function StepperMotor_Holes(t)        = [-t[8]/2, t[8]/2];
function StepperMotor_BigHole(t)      = t[4] + 0.2;
function StepperMotor_Shaft_Dia(t)    = t[6];
function StepperMotor_Shaft_Length(t) = t[7];
function StepperMotor_Hole_Pitch(t)   = t[8];
function StepperMotor_TypeSuffix(t)   = t[9];


// Type Table
//                                   corner  body    boss    boss          shaft
//                     width, length, radius, radius, radius, depth, shaft, length, holes, type
StepperMotor_NEMA17  = [42.3, 47,     53.6/2, 25,     11,     2,     5,     24,     31,   "NEMA17" ];
StepperMotor_NEMA17S = [42.3, 34,     53.6/2, 25,     11,     2,     5,     24,     31,   "NEMA17S" ];
StepperMotor_NEMA14  = [35.2, 36,     46.4/2, 21,     11,     2,     5,     21,     26,   "NEMA14" ];
StepperMotor_NEMA11  = [28.2, 51,     18,     18,     22/2,   2,     5,     21,     23,   "NEMA11" ];


// Type Collection
StepperMotor_Types = [
    StepperMotor_NEMA17,
    StepperMotor_NEMA17S,
    StepperMotor_NEMA14,
    StepperMotor_NEMA11
];

// Vitamin Catalogue
module StepperMotor_Catalogue() {
    for (t = StepperMotor_Types) StepperMotor(t);
}



// Connectors
// ----------

// Face connector - use for attach the motor face to a bracket
StepperMotor_Con_Face				= [ [0,0,0], [0,0,1], 0, 0, 0];

// Shaft connector - use for attaching parts to the end of the shaft
// Conditional on motor type
function StepperMotor_Con_Shaft(t)	= [ [0,0, StepperMotor_Shaft_Length(t)], [0,0,-1], 0, 0, 0];

// Dynamic front fixings connector
// Conditional on motor type (1st param) and fixing position: x=0|1, y=0|1
function StepperMotor_Con_FrontFixing(t, x=0, y=0) = [
    [
        StepperMotor_Holes(t)[x],
        StepperMotor_Holes(t)[y],
        0
    ],
    [0,0,-1],
    0,0,0
];



module StepperMotor(type = StepperMotor_NEMA17) {

    ts = StepperMotor_TypeSuffix(type);

    vitamin("vitamins/StepperMotor.scad", str(ts," Stepper Motor"), str("StepperMotor(StepperMotor_",ts,")")) {
        view(r=[65,0,130], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(StepperMotor_Con_Face);
            connector(StepperMotor_Con_Shaft(type));
            for (x=[0,1], y=[0,1])
                connector(StepperMotor_Con_FrontFixing(type,x,y));

        }

        StepperMotor_Model(type);
    }
}


module StepperMotor_Model(type) {
    side = StepperMotor_Width(type);
    length = StepperMotor_Length(type);
    body_rad = StepperMotor_BodyRadius(type);
    boss_rad = StepperMotor_BossRadius(type);
    boss_height = StepperMotor_BossDepth(type);
    shaft_rad = StepperMotor_Shaft_Dia(type) / 2;
    cap = 8;


    stepper_body_color = Grey20;
    stepper_cap_color  = Grey80;

    union() {
        // black laminations
        color(stepper_body_color) render()
            translate([0,0, -length / 2])
                intersection() {
                    cube([side, side, length - cap * 2],center = true);
                    cylinder(r = body_rad, h = 2 * length, center = true);
                }

        // aluminium end caps
        color(stepper_cap_color) render() {
            difference() {
                union() {
                    intersection() {
                        union() {
                            translate([0,0, -cap / 2])
                                cube([side,side,cap], center = true);
                            translate([0,0, -length + cap / 2])
                                cube([side,side,cap], center = true);
                        }
                        cylinder(r = StepperMotor_BodyRadius(type), h = 3 * length, center = true);
                    }
                    // raised boss
                    difference() {
                        cylinder(r = boss_rad, h = boss_height * 2, center = true);
                        cylinder(r = shaft_rad + 2, h = boss_height * 2 + 1, center = true);
                    }
                    // shaft
                    cylinder(r = shaft_rad, h = StepperMotor_Shaft_Length(type) * 2, center = true);
                }

                // fixing holes
                for(x = StepperMotor_Holes(type))
                    for(y = StepperMotor_Holes(type))
                        translate([x, y, 0])
                            cylinder(r = 3/2, h = 9, center = true);
            }
        }

        // wires
        translate([0, side / 2, -length + cap / 2])
            rotate([90, 0, 0])
                for(i = [0:3])
                    rotate([0, 0, 225 + i * 90])
                        color(["red", "blue","green","black"][i]) render()
                            translate([1, 0, 0])
                                cylinder(r = 1.5 / 2, h = 12, center = true);


    }
}
