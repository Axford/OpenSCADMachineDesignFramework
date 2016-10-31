/*
    Vitamin: Wingnut
    Ported from Mendel90, original script by Nophead
*/


// Dependencies
include <../vitamins/washer.scad>
include <../vitamins/nut.scad>


// Connectors

wingnut_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



// Types

M4_wingnut = ["M4_wingnut", 4, 10, 3.75, 8, M4_washer, 0, 22, 10, 6, 3, M4_nut];


function wingnut_typename(t)       = t[0];
function wingnut_diameter(t)       = t[1];
function wingnut_bottomdiameter(t) = t[2];
function wingnut_thickness(t)      = t[3];
function wingnut_topdiameter(t)    = t[4];
function wingnut_washer(t)         = t[5];
function wingnut_wingspan(t)       = t[7];
function wingnut_wingheight(t)     = t[8];
function wingnut_wingwidth(t)      = t[9];
function wingnut_wingthickness(t)  = t[10];
function wingnut_nuttype(t)        = t[11];


module wingnut(type=M4_wingnut) {

    vitamin("vitamins/wingnut.scad", str("Wingnut M", wingnut_diameter(type)), str("wingnut(",wingnut_typename(type),")")) {
        view(d=200);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(wingnut_Con_Def);
        }

        // model
        wingnut_Body(type);
    }
}

module wingnut_Body(type) {
    part(str("wingnut_Body_",wingnut_typename(type)), str("wingnut_Body(",wingnut_typename(type),")"));

    color(MetalColor)
        if (UseVitaminSTL) {
            import(str(VitaminSTL,str("wingnut_Body_",wingnut_typename(type),".stl")));
        }
        else
        {
            wingnut_Model(type);

        }
}

module wingnut_Model(type) {
    hole_rad  = wingnut_diameter(type) / 2;
    bottom_rad = wingnut_bottomdiameter(type) / 2;
    top_rad = wingnut_topdiameter(type) / 2;
    thickness = wingnut_thickness(type);
    wing_span = wingnut_wingspan(type);
    wing_height = wingnut_wingheight(type);
    wing_width = wingnut_wingwidth(type);
    wing_thickness = wingnut_wingthickness(type);

    top_angle = asin((wing_thickness / 2) / top_rad);
    bottom_angle = asin((wing_thickness / 2) / bottom_rad);

    difference() {
        union() {
            cylinder(r1 = bottom_rad, r2 = top_rad, h = thickness);
            for(rot = [0, 180])
                rotate([90, 0, rot]) linear_extrude(height = wing_thickness, center = true)
                    hull() {
                        translate([wing_span / 2  - wing_width / 2, wing_height - wing_width / 2])
                            circle(r = wing_width / 2, center = true);
                        polygon([
                            [bottom_rad * cos(top_angle) - eta, 0],
                            [wing_span / 2  - wing_width / 2, wing_height - wing_width / 2],
                            [top_rad * cos(top_angle) - eta, thickness],
                            [bottom_rad * cos(top_angle) - eta, 0],
                        ]);
                    }
        }
        translate([0,0,-1])
            cylinder(r = hole_rad, h = thickness + 2);
    }
}
