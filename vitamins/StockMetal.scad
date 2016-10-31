/*
    Vitamin: Stock Metal

    Models for various stock metal profiles, including:
     * Angles
     * Box section
     * Channels
     * Flat/square Bar
     * Hex bar
     * Round bar
     * Round tube
     * Tee section

    Profile dimensions are fixed except for length, which is expected to be rounded to nearest mm.
    All internal dimensions are in mm, descriptions can be in metric or imperial

    Dependent on the Materials vitamin

    Local Frame:
      * For symmetric profiles: Centred on the origin, lying on the XY plane, height/length extending along z+
      * For asymmetric profiles (e.g. angle, channel) - bottom left corner at origin, height/length along z+
           Long edge along x+, short edge along y+
*/


// Dependencies
include <../vitamins/Material.scad>


// Connectors

StockMetal_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];


// Types
// -----

// Profile type
StockMetal_Angle     = 0;
StockMetal_Box       = 1;
StockMetal_Channel   = 2;
StockMetal_FlatBar   = 3;
StockMetal_HexBar    = 4;
StockMetal_RoundBar  = 5;
StockMetal_Tube      = 6;  // round
StockMetal_Tee       = 7;

// Units
StockMetal_Metric = 0;
StockMetal_Imperial = 1;

function StockMetal_TypeSuffix(t)  = t[0];
function StockMetal_Description(t) = t[1];
function StockMetal_Profile(t)     = t[2];
function StockMetal_Dims(t)        = t[3];
function StockMetal_Units(t)       = t[4];


// Types
// Order by ProfileType, then Units, then Dimensions
// Dimensions should be Descending order
// Don't forget to add new types to the Type Collection

//                           TypeSuffix,         Description,             ProfileType,      Fixed Dimensions, Units
StockMetal_Angle_20x20x3   = ["Angle_20x20x3",   "Angle 20x20x3mm",       StockMetal_Angle, [20,20,3],        StockMetal_Metric  ];
StockMetal_Angle_30x20x1p5 = ["Angle_30x20x1p5", "Angle 30x20x1.5mm",     StockMetal_Angle, [30,20,1.5],      StockMetal_Metric  ];

//                           TypeSuffix,         Description,             ProfileType,      Fixed Dimensions, Units
StockMetal_Box_30x30x3     = ["Box_30x30x3",     "Box Section 30x30x3mm", StockMetal_Box,   [30,30,3],        StockMetal_Metric  ];

// Channel dimensions = bottom width x side height x bottom_thickness x side_thickness
//                               TypeSuffix,               Description,              ProfileType,        Fixed Dimensions, Units
StockMetal_Channel_40x25x3x3 =   ["Channel_40x25x3x3",     "Channel 40x25x3x3mm",    StockMetal_Channel, [40,25,3,3],       StockMetal_Metric  ];

StockMetal_Channel_4x1x1d8x1d8i = ["Channel_4x1x1d8x1d8i",   "Channel 4x1x1/8x1/8 in", StockMetal_Channel, [101.6,25.4,3.18,3.18],       StockMetal_Imperial  ];
StockMetal_Channel_4x2x1d8x1d8i = ["Channel_4x2x1d8x1d8i",   "Channel 4x2x1/8x1/8 in", StockMetal_Channel, [101.6,50.8,3.18,3.18],       StockMetal_Imperial  ];


//                           TypeSuffix,         Description,             ProfileType,         Fixed Dimensions, Units
StockMetal_FlatBar_6x1 =    ["FlatBar_6x1",     "Flat Bar 6x1mm",        StockMetal_FlatBar,  [6,1],            StockMetal_Metric  ];

//                           TypeSuffix,         Description,             ProfileType,      Fixed Dimensions, Units
//TODO: StockMetal_HexBar

//                           TypeSuffix,         Description,      ProfileType,         Fixed Dimensions, Units
StockMetal_RoundBar_2      = ["RoundBar_2",     "Round Bar 2mm",   StockMetal_RoundBar, [2],              StockMetal_Metric  ];
StockMetal_RoundBar_6      = ["RoundBar_6",     "Round Bar 6mm",   StockMetal_RoundBar, [6],              StockMetal_Metric  ];
StockMetal_RoundBar_8      = ["RoundBar_8",     "Round Bar 8mm",   StockMetal_RoundBar, [8],              StockMetal_Metric  ];
StockMetal_RoundBar_10     = ["RoundBar_10",    "Round Bar 10mm",  StockMetal_RoundBar, [10],             StockMetal_Metric  ];
StockMetal_RoundBar_12     = ["RoundBar_12",    "Round Bar 12mm",  StockMetal_RoundBar, [12],             StockMetal_Metric  ];
StockMetal_RoundBar_20     = ["RoundBar_20",    "Round Bar 20mm",  StockMetal_RoundBar, [20],             StockMetal_Metric  ];


// Dimensions = OD x wall thickness
//                           TypeSuffix,         Description,      ProfileType,     Fixed Dimensions, Units
StockMetal_Tube_10x1       = ["Tube_10x1",       "Tube 10x1mm",    StockMetal_Tube, [10,1],           StockMetal_Metric  ];
StockMetal_Tube_10x1p5     = ["Tube_10x1p5",     "Tube 10x1.5mm",  StockMetal_Tube, [10,1.5],           StockMetal_Metric  ];

//                           TypeSuffix,         Description,             ProfileType,      Fixed Dimensions, Units
//TODO: StockMetal_Tee



// Type Collection
StockMetal_Types = [
    StockMetal_Angle_20x20x3,
    StockMetal_Angle_30x20x1p5,

    StockMetal_Box_30x30x3,

    StockMetal_FlatBar_6x1,

    StockMetal_Channel_40x25x3x3,
    StockMetal_Channel_4x1x1d8x1d8i,
    StockMetal_Channel_4x2x1d8x1d8i,

    StockMetal_RoundBar_2,
    StockMetal_RoundBar_6,
    StockMetal_RoundBar_8,
    StockMetal_RoundBar_10,
    StockMetal_RoundBar_12,
    StockMetal_RoundBar_20,

    StockMetal_Tube_10x1,
    StockMetal_Tube_10x1p5
];


// Vitamin Catalogue
module StockMetal_Catalogue() {
    for (t = StockMetal_Types) StockMetal(t);
}


module StockMetal(type=StockMetal_Angle_20x20x3, size=100, material=Material_Alu) {

    ts = StockMetal_TypeSuffix(type);
    p = StockMetal_Profile(type);
    d = StockMetal_Description(type);
    sizer = round(size);

    nameStr = str(Material_Description(material)," ",d," x ",sizer,"mm");
    callStr = str("StockMetal(type=StockMetal_",ts,", size=",sizer,", material=Material_",Material_TypeSuffix(material),")");

    vitamin("vitamins/StockMetal.scad", nameStr, callStr) {
        view(t=[20, 25, 35], r=[170,0,90], d=400);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(StockMetal_Con_Def);
        }

        color(Material_Color(material)) {
            if (p == StockMetal_Angle) {
                StockMetal_Angle_Model(type, sizer, material);
            } else if (p == StockMetal_Box) {
                StockMetal_Box_Model(type, sizer, material);
            } else if (p == StockMetal_FlatBar) {
                StockMetal_FlatBar_Model(type, sizer, material);
            } else if (p == StockMetal_Channel) {
                StockMetal_Channel_Model(type, sizer, material);
            } else if (p == StockMetal_RoundBar) {
                StockMetal_RoundBar_Model(type, sizer, material);
            } else if (p == StockMetal_Tube) {
                StockMetal_Tube_Model(type, sizer, material);
            } else {
                // default - unknown!
                debug("ERROR: StockMetal - Unknown profile type!");
            }
        }

    }
}

module StockMetal_Angle_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_Angle) {
        union() {
            cube([d[0], d[2], size]);
            cube([d[2], d[1], size]);
        }
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}

module StockMetal_Box_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_Box) {
        linear_extrude(size)
            hollowSquare([d[0],d[1]], [d[0]-2*d[2], d[1]-2*d[2]], center=true);
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}

module StockMetal_FlatBar_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_FlatBar) {
        linear_extrude(size)
            square([d[0],d[1]], center=true);
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}

module StockMetal_Channel_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_Channel) {
        union() {
            cube([d[3], d[1], size]);
            cube([d[0], d[2], size]);
            translate([d[0] - d[3],0,0])
                cube([d[3], d[1], size]);
        }
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}



module StockMetal_RoundBar_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_RoundBar) {
        cylinder(r=d[0]/2, h=size, $fn=16);
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}

module StockMetal_Tube_Model(type, size, material) {
    p = StockMetal_Profile(type);
    d = StockMetal_Dims(type);

    if (p == StockMetal_Tube) {
        tube(or=d[0]/2, ir=d[0]/2-d[1], h=size, $fn=16);
    } else {
        debug("ERROR: StockMetal - Unknown profile type!");
    }
}
