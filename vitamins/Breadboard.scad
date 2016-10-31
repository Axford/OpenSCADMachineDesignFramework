/*
	Vitamin: Breadboard
	Various common breadboard models

	Authors:
		Damian Axford

	Local Frame:
		Bottom corner at the origin, width is in x+, depth is in y+

	Parameters:
		BreadboardType - One of a set of Breadboard types
		ShowPins - boolean
		BoardColor - color

	Connectors:
		BottomLeft, TopLeft, BottomRight, TopRight

	Returns:
		A Breadboard model, colored
*/

// Breadboard Global Variables

Breadboard_PinSpacing = 2.54;  // 0.1 inch pitch
Breadboard_PinWidth   = 1;

// Breadboard Types

//                Width, Depth, Thickness, PinsWide, PowerRails, PowerRailGrouping, GutterWidth, MountPoints, MountInsetX, MountInsetY, MountBore, TypeName
Breadboard_170 = [ 47,    35,    8.5,       17,       0,          0,                 31,          2,           5,           0,          3.5,       "170" ];

Breadboard_270 = [ 85.4,  45,    8.3,       23,       1,          5,                 58,          4,           5,           6,          4.5,       "270"  ];

Breadboard_400 = [ 85,   55,    9.7,        30,       2,          5,                 83,          0,           5,           6,          4.5,       "400"  ];


Breadboard_Types = [
	Breadboard_170,
	Breadboard_270,
	Breadboard_400
];

module Breadboard_Catalogue() {
    // output a set of vitamin() calls to be used to construct the vitamin catalogue
    for (t = Breadboard_Types) Breadboard(t);
}

// Breadboard Type Getters

function Breadboard_Width(BreadboardType) = BreadboardType[0];
function Breadboard_Depth(BreadboardType) = BreadboardType[1];
function Breadboard_Height(BreadboardType) = BreadboardType[2];
function Breadboard_PinsWide(BreadboardType) = BreadboardType[3];
function Breadboard_PowerRails(BreadboardType) = BreadboardType[4];
function Breadboard_PowerRailGrouping(BreadboardType) = BreadboardType[5];
function Breadboard_GutterWidth(BreadboardType) = BreadboardType[6];
function Breadboard_MountPoints(BreadboardType) = BreadboardType[7];
function Breadboard_MountInsetX(BreadboardType) = BreadboardType[8];
function Breadboard_MountInsetY(BreadboardType) = BreadboardType[9];
function Breadboard_MountBore(BreadboardType) = BreadboardType[10];
function Breadboard_TypeName(BreadboardType) = BreadboardType[11];

// Breadboard Utility Getters

function Breadboard_ConnectorHeight(BreadboardType) = Breadboard_MountPoints(BreadboardType) > 2 ? Breadboard_Height(BreadboardType)/2 : Breadboard_Height(BreadboardType);


// Breadboard Connector Getters

function Breadboard_Con_BottomLeft(BreadboardType) = [
	[
		Breadboard_MountInsetX(BreadboardType),
		Breadboard_MountPoints(BreadboardType) > 2 ? Breadboard_MountInsetY(BreadboardType) : Breadboard_Depth(BreadboardType)/2,
		Breadboard_ConnectorHeight(BreadboardType)
	],
	[0, 0, -1],
	0, 0, 0
	];

function Breadboard_Con_TopLeft(BreadboardType) = [
	[
		Breadboard_MountInsetX(BreadboardType),
		Breadboard_MountPoints(BreadboardType) > 2 ? Breadboard_Depth(BreadboardType)-Breadboard_MountInsetY(BreadboardType) : Breadboard_Depth(BreadboardType)/2,
		Breadboard_ConnectorHeight(BreadboardType)
	],
	[0, 0, -1],
	0, 0, 0
	];

function Breadboard_Con_BottomRight(BreadboardType) = [
	[
		Breadboard_Width(BreadboardType) - Breadboard_MountInsetX(BreadboardType),
		Breadboard_MountPoints(BreadboardType) > 2 ? Breadboard_MountInsetY(BreadboardType) : Breadboard_Depth(BreadboardType)/2,
		Breadboard_ConnectorHeight(BreadboardType)
	],
	[0, 0, -1],
	0, 0, 0
	];

function Breadboard_Con_TopRight(BreadboardType) = [
	[
		Breadboard_Width(BreadboardType) - Breadboard_MountInsetX(BreadboardType),
		Breadboard_MountPoints(BreadboardType) > 2 ? Breadboard_Depth(BreadboardType)-Breadboard_MountInsetY(BreadboardType) : Breadboard_Depth(BreadboardType)/2,
		Breadboard_ConnectorHeight(BreadboardType)
	],
	[0, 0, -1],
	0, 0, 0
	];


// all connectors in an array - use Breadboard_MountPoints() as max iterator value
function Breadboard_Cons(BreadboardType) = [
        Breadboard_Con_BottomLeft(BreadboardType),
        Breadboard_Con_BottomRight(BreadboardType),
        Breadboard_Con_TopLeft(BreadboardType),
        Breadboard_Con_TopRight(BreadboardType)
    ];

// dynamic connector to locate a particular pin on the breadboard
// along is in x, across in in y, both numbered from 1
function Breadboard_Con_Pin(t, along, across, ang) = [
    [
        (Breadboard_Width(t) - ((Breadboard_PinsWide(t)-1) * Breadboard_PinSpacing))/2 + (along-1) * Breadboard_PinSpacing,
        Breadboard_Depth(t)/2 + (across < 6 ? -1 : 1) * ( (3*2.54/2) + (across < 6 ? 5-across : across-6) * Breadboard_PinSpacing ),
        Breadboard_Height(t)
    ],
    [0,0,-1],
    ang,0,0
];


module Breadboard(BreadboardType = Breadboard_170, ShowPins=true, BoardColor = "white") {

	// local shortcuts

	ps = Breadboard_PinSpacing;
	pw = Breadboard_PinWidth;

	w = Breadboard_Width(BreadboardType);
	d = Breadboard_Depth(BreadboardType);
	h = Breadboard_Height(BreadboardType);
	pinsWide = Breadboard_PinsWide(BreadboardType);
	pr = Breadboard_PowerRails(BreadboardType);
	prg = Breadboard_PowerRailGrouping(BreadboardType);
	gw = Breadboard_GutterWidth(BreadboardType);
	mp =  Breadboard_MountPoints(BreadboardType);
	mix = Breadboard_MountInsetX(BreadboardType);
	miy = Breadboard_MountInsetY(BreadboardType);
	mb = Breadboard_MountBore(BreadboardType);
	tn = Breadboard_TypeName(BreadboardType);

	// calculations

	// x offset for main pains
	pox = (w - ((pinsWide-1) * ps))/2;

	// number of power rail pin groups
	prgs = round(pinsWide / (prg + 1));

	// equivalent total number of power pins
	prp = prgs * (prg + 1) - 1;

	// power pin offset, for uneven numbers of power pins
	prpo = (pinsWide - prp) * ps / 2;

	vitamin("vitamins/Breadboard.scad", str("Breadboard ",tn), str("Breadboard(Breadboard_",tn,")")) {
	    view(d=400);

        if (DebugCoordinateFrames) frame();

        if (DebugConnectors) {
            if (mp > 0) {
                connector(Breadboard_Con_BottomLeft(BreadboardType));
                connector(Breadboard_Con_BottomRight(BreadboardType));
            }
            if (mp > 2) {
                connector(Breadboard_Con_TopLeft(BreadboardType));
                connector(Breadboard_Con_TopRight(BreadboardType));
            }
        }

        // Base
        color(BoardColor)
            render()
            difference() {
                // Starting cuboid
                cube([w, d, h]);

                // mounting holes + countersinks
                if (mp > 0) {
                    for (x=[-1,1])
                        translate([w/2 + x * (w/2 - mix), d/2, -1])
                        if (mp == 2) {
                            cylinder(r=4/2, h=h+2, $fn=16);
                        } else {
                            for (y=[-1,1])
                                translate([0, y * (d/2 - miy), 0]) {
                                    // bore
                                    cylinder(r=mb/2*0.8, h=h+2, $fn=12);

                                    // CS
                                    translate([0,0, h/2])
                                        cylinder(r=mb/2, h=h+2, $fn=16);
                                }
                        }
                }

                // central gutter
                translate([w/2, d/2, 2 + h/2])
                    cube([gw, 4, h], center=true);
            }

        // Pins
        // - Cheap hack to draw quickly by drawing pins as individual 2D squares
        if (ShowPins)
            color("black")
            translate([0, 0, h-0.3])
            {
                // inner pins
                for (x=[0:pinsWide-1], y=[0:4], m=[-1,1])
                    translate([pox + x * ps, d/2 + m * ( (3*2.54/2) + y * ps )])
                    square([pw,pw], center=true);

                // power rails
                if (pr > 0) {
                    for (g=[0:prgs-1])
                        translate([pox + prpo + g * ((prg+1) * ps), 0, 0])
                        for (x=[0:prg-1], y=[0:pr-1], m=[-1,1])
                        translate([x * ps, d/2 + m * ( (3*2.54/2 + 5*2.54 + 2.54) + y * ps )])
                        square([pw,pw], center=true);
                }
            }
	}
}
