/*
    Vitamin: DC Motor

    Local Frame:
        Motor centred on XY origin
        Shaft points up (Z+)
        Mounting face of motor is at Z=0 (boss will extend along Z+)

*/


// Types
// -----

/*
    Model is parameterised in several parts:
       FrontShaft
       FrontBoss - protrudes from the face of the motor
       FrontCan - gearbox, reduced diameter for mounting, etc - may be zero
       FrontFixings

       RearCan - main motor region
       RearBoss - protrudes from the rear of the motor
       RearShaft
       RearFixings

       Terminals
*/

// Type getters
function DCMotor_TypeSuffix(t)         = t[0];
function DCMotor_FrontCan_OD(t)        = t[1];
function DCMotor_FrontCan_Length(t)    = t[2];
function DCMotor_RearCan_OD(t)         = t[3];
function DCMotor_RearCan_Length(t)     = t[4];
function DCMotor_FrontShaft_OD(t)      = t[5];
function DCMotor_FrontShaft_Length(t)  = t[6];
function DCMotor_FrontBoss_OD(t)       = t[7];
function DCMotor_FrontBoss_Length(t)   = t[8];
function DCMotor_RearBoss_OD(t)        = t[9];
function DCMotor_RearBoss_Length(t)    = t[10];
function DCMotor_FrontFixings(t)       = t[11];  // how many fixings, 0=none, assumed equal angular spacing
function DCMotor_FrontFixing_OD(t)     = t[12];  // fixing diameter, e.g. 3mm
function DCMotor_FrontFixing_Radius(t) = t[13];  // distance from shaft
function DCMotor_Terminal_Type(t)      = t[14];  // 0 = adjacent wires (single bundle), 1 = opposite wires, 2 = tabs
function DCMotor_Terminal_Radius(t)    = t[15];  // distance from shaft
function DCMotor_Terminal_Size(t)      = t[16];  // [width,length] for wires width is diameter


// Type table
//                     Type suffix,  FC_OD, FC_L, RC_OD, RC_L, FS_OD, FS_L, FB_OD, FB_L, RB_OD, RB_L, F, F_OD, F_R,  T_T, T_R,  T_S
DCMotor_R260        = ["R260",       19,    3.5,  23.8,  23.5, 2,     8.5,  6,     1.6,  10,    2,    2, 2.3,  5.75, 2,   8.75, [3,5] ];
DCMotor_CL072014    = ["CL072014",   0,     0,    7,     20,   1,     5,    2,     0.5,  0,     0,    0, 0,    0,    0,   3,    [0.7,5] ];


// Type Collection
DCMotor_Types = [
    DCMotor_R260,
    DCMotor_CL072014
];

// Vitamin Catalogue
module DCMotor_Catalogue() {
    for (t = DCMotor_Types) DCMotor(t);
}



// Connectors
// ----------

// Face connector - use for attach the motor face to a bracket
DCMotor_Con_Face				= [ [0,0,0], [0,0,1], 0, 0, 0];

// Shaft connector - use for attaching parts to the end of the shaft
// Conditional on motor type
function DCMotor_Con_Shaft(t)	= [ [0,0, DCMotor_FrontShaft_Length(t)], [0,0,-1], 0, 0, 0];

// Dynamic front fixings connector
// Conditional on motor type (1st param) and fixing number (2nd param)
function DCMotor_Con_FrontFixing(t, num) = [
    [DCMotor_FrontFixing_Radius(t) * cos(360 * (num-1) / DCMotor_FrontFixings(t)), DCMotor_FrontFixing_Radius(t) * sin(360 * (num-1) / DCMotor_FrontFixings(t)), 0],
    [0,0,-1],
    0,0,0
];


module DCMotor(type=DCMotor_R260) {

    ts = DCMotor_TypeSuffix(type);
    f = DCMotor_FrontFixings(type);

    vitamin("vitamins/DCMotor.scad", str(ts," DC Motor"), str("DCMotor(DCMotor_",ts,")")) {
        view(r=[340,25,0], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(DCMotor_Con_Face);
            connector(DCMotor_Con_Shaft(type));
            if (f > 0)
                for (i=[1:f])
                connector(DCMotor_Con_FrontFixing(type, i));
        }

        DCMotor_Model(type);
    }
}

module DCMotor_Model(t) {
    fcod = DCMotor_FrontCan_OD(t);
    fcl = DCMotor_FrontCan_Length(t);
    rcod = DCMotor_RearCan_OD(t);
    rcl = DCMotor_RearCan_Length(t);
    fsod = DCMotor_FrontShaft_OD(t);
    fsl = DCMotor_FrontShaft_Length(t);
    fbod = DCMotor_FrontBoss_OD(t);
    fbl = DCMotor_FrontBoss_Length(t);
    rbod = DCMotor_RearBoss_OD(t);
    rbl = DCMotor_RearBoss_Length(t);
    f = DCMotor_FrontFixings(t);
    fod = DCMotor_FrontFixing_OD(t);
    fr = DCMotor_FrontFixing_Radius(t);
    tt = DCMotor_Terminal_Type(t);
    tr = DCMotor_Terminal_Radius(t);
    ts = DCMotor_Terminal_Size(t);

    l = fcl+rcl;  // length of motor body, excluding bosses

    // Front shaft
    color(MetalColor)
        cylinder(r=fsod/2, h=fsl);

    // Body
    color(MetalColor)
        difference() {
            union() {
                // Front boss
                color(MetalColor)
                    cylinder(r=fbod/2, h=fbl);

                // Front can
                color(Grey50)
                    translate([0,0,-fcl])
                    cylinder(r=fcod/2, h=fcl+eta);

                // Rear can
                color(MetalColor)
                    translate([0,0,-l])
                    cylinder(r=rcod/2, h=rcl + eta);

                // Rear boss
                color(MetalColor)
                    translate([0,0,-l-rbl])
                    cylinder(r=rbod/2, h=rbl + eta);
            }

            // Front fixings
            if (f > 0) {
                for (i=[1:f])
                    attach(offsetConnector(DCMotor_Con_FrontFixing(t, i), [0,0,1]), DefConUp)
                    cylinder(r=fod/2, h=rcl+fcl-1);
            }

        }

    // Terminals/wires
    if (tt == 0) {
        // adjacent wires
        color("black")
            translate([tr,ts[0]/2,-l-ts[1]])
            cylinder(r=ts[0]/2, h=ts[1]);
        color("red")
            translate([tr,-ts[0]/2,-l-ts[1]])
            cylinder(r=ts[0]/2, h=ts[1]);


    } else if (tt == 1) {
        // opposite wires
        color("black")
            translate([-tr,0,-l-ts[1]])
            cylinder(r=ts[0]/2, h=ts[1]);
        color("red")
            translate([tr,0,-l-ts[1]])
            cylinder(r=ts[0]/2, h=ts[1]);

    } else {
        // tabs
        color("gold")
            for (x=[0:1])
            mirror([x,0,0])
            translate([tr, -ts[0]/2,-l-ts[1]])
            chamferedCubeX([0.5, ts[0], ts[1] + ts[0]/6], ts[0]/6);

    }
}
