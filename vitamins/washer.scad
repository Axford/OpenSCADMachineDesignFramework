//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//
M2_washer  =      [2,   6, 0.5, false,  5.8, "M2_washer"];
M2p5_washer=      [2.5, 5.9, 0.5, false,  5.4, "M2p5_washer"];
M3_washer  =      [3,   7, 0.5, false,  5.8, "M3_washer"];
M3_penny_washer  =[3,  12, 0.8, false,  5.8, "M3_penny_washer"];
M3p5_washer  =    [3.5, 8, 0.5, false,  6.9, "M3p5_washer"];
M4_washer  =      [4,   9, 0.8, false,  7.9, "M4_washer"];
M5_washer  =      [5,  10, 1.0, false,    9, "M5_washer"];
M5_penny_washer = [5,  20, 1.4, false,  8.8, "M5_penny_washer"];
M6_washer  =      [6,  12, 1.5, false, 10.6, "M6_washer"];
M8_washer =       [8,  17, 1.8, false, 13.8, "M8_washer"];
M8_penny_washer = [8,  30, 1.5, false, 13.8, "M8_penny_washer"];
M10_washer =      [10,  21, 2.2, false, 15.8, "M10_washer"];

M3_rubber_washer= [3,  10, 1.5, true, 0, "M3_rubber_washer"];

washer_types = [
    M2_washer,
    M2p5_washer,
    M3_washer,
    M3p5_washer,
    M4_washer,
    M5_washer,
    M5_penny_washer,
    M6_washer,
    M8_washer,
    M8_penny_washer,
    M10_washer,
    M3_rubber_washer
];

function washer_diameter(type)  = type[1];
function washer_radius(type)    = type[1]/2;
function washer_clearance_radius(type) = type[1]/2 + 0.2;
function washer_thickness(type) = type[2];
function washer_soft(type)      = type[3];
function washer_color(type) = washer_soft(type) ? Grey20 : MetalColor;
function star_washer_diameter(type) = type[4];


module washer_Catalogue() {
    // output a set of vitamin() calls to be used to construct the vitamin catalogue
    for (t = washer_types) washer(t);
}

module washer(type=M4_washer, ExplodeSpacing=10) {
    hole = type[0];
    thickness = washer_thickness(type);
    diameter  = washer_diameter(type);

    vitamin(
        "vitamins/washer.scad",
        str("M",hole, washer_soft(type) ? " Rubber":""  ," Washer ",diameter,"x",thickness),
        str("washer(type=",type[5],")")
    ) {
        view(d=200);
    }

    color(washer_color(type)) render() difference() {
        cylinder(r = diameter / 2, h = thickness - 0.05);
        cylinder(r = hole / 2, h = 2 * thickness + 1, center = true);
    }

    if($children)
        for(i=[0:$children-1])
            attach(offsetConnector(DefConDown, [0,0,thickness]), DefConDown, ExplodeSpacing=ExplodeSpacing * (i+1))
            children(i);
}

// FIXME: Update star_washer to new format
module star_washer(type) {
    hole = type[0];
    thickness = washer_thickness(type);
    diameter  = star_washer_diameter(type);
    rad = diameter / 2;
    inner = (hole / 2 + rad) / 2;
    spoke  = rad - hole / 2;
    vitamin(str("WS", hole * 10, washer_diameter(type), thickness * 10,
                ": Star washer M", hole, " x ", thickness, "mm"));
    color(star_washer_color) render() difference() {
        cylinder(r = rad, h = thickness);
        cylinder(r = hole / 2, h = 2 * thickness + 1, center = true);
        for(a = [0:30:360])
            rotate([0, 0, a])
                translate([inner + spoke / 2, 0, 0.5])
                    cube([spoke, 2 * 3.142 * inner / 36,  thickness + 1], center = true);
    }
    if($children)
        translate([0, 0, thickness])
            children();
}
