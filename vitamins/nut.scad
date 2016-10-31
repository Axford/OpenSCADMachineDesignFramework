//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//

include <../vitamins/washer.scad>

M2_nut      = [2, 4.3, 1.6, 3.5,    M2_washer,     M2_nut_trap_depth, "M2_nut", false];
M2p5_nut  = [2.5, 5.8, 2.2, 3.8,  M2p5_washer, M2p5_nut_trap_depth, "M2p5_nut", false];
M3_nut      = [3, 6.4, 2.4, 4,    M3_washer,     M3_nut_trap_depth, "M3_nut", false];
M4_nut      = [4, 8.1, 3.2, 5,    M4_washer,     M4_nut_trap_depth, "M4_nut", false];
M5_nut      = [5, 9.2,   4, 6.25, M5_washer,     M5_nut_depth, "M5_nut", false];
M6_nut      = [6, 11.5,  5, 8,    M6_washer,     M6_nut_depth, "M6_nut", false];
M6_half_nut = [6, 11.5,  3, 8,    M6_washer,     3, "M6_half_nut", true];
M8_nut      = [8, 15,  6.5, 8,    M8_washer,     M8_nut_depth, "M8_nut", false];
M10_nut     = [10, 19.6,  8, 8,   M10_washer,    M10_nut_depth, "M10_nut", false];

nut_types = [
    M2_nut,
    M2p5_nut,
    M3_nut,
    M4_nut,
    M5_nut,
    M6_nut,
    M6_half_nut,
    M8_nut,
    M10_nut
];

module nut_Catalogue() {
    // output a set of vitamin() calls to be used to construct the vitamin catalogue
    for (t = nut_types) nut(t);
}

function nut_radius(type) = type[1] / 2;
function nut_flat_radius(type) = nut_radius(type) * cos(30);
function nut_thickness(type, nyloc = false) = nyloc ? type[3] : type[2];
function nut_washer(type) = type[4];
function nut_trap_depth(type) = type[5];

screw_pan_color = [0.7,0.7,0.7];

module nut(type=M4_nut, nyloc = false, brass = false, ExplodeSpacing=10) {
    hole_rad  = type[0] / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = type[3];

    vitamin(
        "vitamins/nut.scad",
        str(nyloc?"Nyloc " : "", brass?"Brass ":"", "M", type[0], type[7] ? " Half" : "" , " Nut"),
        str("nut(type=",type[6],",nyloc=",nyloc,",brass=",brass," )")
    ) {
        view(d=200);
    }

    color(brass? brass_nut_color : nut_color) render() difference() {
        union() {
            cylinder(r = outer_rad, h = thickness, $fn = 6);
            if(nyloc)
                translate([0,0, eta])
                    rounded_cylinder(r = outer_rad * cos(30) , h = nyloc_thickness, r2 = (nyloc_thickness - thickness) / 2);
        }
        translate([0, 0, -1])
            cylinder(r = hole_rad, h = nyloc_thickness + 2);
    }

    if($children)
        for(i=[0:$children-1])
            attach(offsetConnector(DefConDown, [0,0,thickness]), DefConDown, ExplodeSpacing=ExplodeSpacing * (i+1))
            children(i);
}

module nut_and_washer(type, nyloc) {
    washer = nut_washer(type);
    washer(washer);
    translate([0,0, washer_thickness(washer)])
        nut(type, nyloc);
}
