/*
    Vitamin: Linear Bearing
    Common LMxxUU linear bearings

    Local Frame:
        Centred on shaft, shaft lies along Z axis

*/


// Type Getters
function LinearBearing_TypeSuffix(t) = t[0];
function LinearBearing_OD(t)         = t[2];
function LinearBearing_OR(t)         = t[2] / 2;
function LinearBearing_Height(t)     = t[1];
function LinearBearing_ID(t)         = t[3];
function LinearBearing_B(t)          = t[4];
function LinearBearing_W(t)          = t[5];
function LinearBearing_D1(t)         = t[6];


// Type table
//                      TypeSuffix, h,  od, id, b,    w,    d1
LinearBearing_LM25UU = ["LM25UU",   59, 40, 25, 41,   1.85, 38];
LinearBearing_LM20UU = ["LM20UU",   42, 32, 20, 30.5, 1.6,  30.5];
LinearBearing_LM16UU = ["LM16UU",   37, 28, 16, 26.5, 1.6,  27];
LinearBearing_LM12UU = ["LM12UU",   30, 21, 12, 23,   1.3,  20];
LinearBearing_LM10UU = ["LM10UU",   29, 19, 10, 22,   1.3,  18];
LinearBearing_LM8UU  = ["LM8UU",    24, 15,  8, 17.5, 1.1,  14.3];
LinearBearing_LM6UU  = ["LM6UU",    19, 12,  6, 13.5, 1.1,  11.5];
LinearBearing_LM4UU  = ["LM4UU",    12,  8,  4, 0,    0,    7.5];

// Dimensions from: http://usih.merchantrunglobal.com/ImageHosting/ViewImage.aspx?GlobalID=1004&MerchantID=10602&ImageID=2197&DisplaySize=-1&ListingID=24321


// Type collection
LinearBearing_Types = [
    LinearBearing_LM25UU,
    LinearBearing_LM20UU,
    LinearBearing_LM16UU,
    LinearBearing_LM12UU,
    LinearBearing_LM10UU,
    LinearBearing_LM8UU,
    LinearBearing_LM6UU,
    LinearBearing_LM4UU
];


// Vitamin catalogue
module LinearBearing_Catalogue() {
    for (t = LinearBearing_Types) LinearBearing(t);
}

// Connectors

// Shaft connector - centred on shaft, shaft lies in Z axis
LinearBearing_Con_Shaft				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module LinearBearing(type=LinearBearing_LM10UU) {

    ts = LinearBearing_TypeSuffix(type);

    vitamin("vitamins/LinearBearing.scad", str(ts," Linear Bearing"), str("LinearBearing(LinearBearing_",ts,")")) {
        view(r=[55,0,50], d=250);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(LinearBearing_Con_Shaft);
        }

        LinearBearing_Model(type);
    }
}


module LinearBearing_Model(t) {
    or = LinearBearing_OD(t) / 2;
    id = LinearBearing_ID(t);
    h = LinearBearing_Height(t);
    b = LinearBearing_B(t);
    w = LinearBearing_W(t);
    d1 = LinearBearing_D1(t);
    chamfer = or - d1/2;

    color(MetalColor)
        render()
        rotate_extrude()
            difference() {
                hull() {
                    translate([0, -h/2, 0])
                        square([or-chamfer, h]);
                    translate([0, chamfer -h/2, 0])
                        square([or, h-2*chamfer]);
                }

                // notches
                if (w > 0) {
                    for (i=[0,1])
                        mirror([0,i,0])
                        translate([d1/2, b/2 - w, 0])
                        square([100, w]);
                }

                // shaft
                square([id, h], center=true);
            }

}
