//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Ball bearings
//


// Type getters

function ball_bearing_id(type) = type[0];
function ball_bearing_od(type) = type[1];
function ball_bearing_diameter(type) = type[1];
function ball_bearing_width(type) = type[2];

// Type table
//            id, od, t,  label
BB623      = [3,  10, 4,  "623"];            // 623 bearings
BB624      = [4,  13, 5,  "624"];            // 624 ball bearing for idlers
BB608      = [8,  22, 7,  "608"];            // 608 bearings for wades
BB625_2RS  = [5,  16, 5,  "625_2RS"];    //  625 bearings for Delrin v groove wheels
BB6205_2RS = [25, 52, 15, "6205_2RS"];

// Type collection
ball_bearing_types = [
    BB623,
    BB624,
    BB608,
    BB625_2RS,
    BB6205_2RS
];

// connectors
ball_bearing_Con_Def = [[0,0,0], [0,0,1], 0,0,0];
function ball_bearing_Con_Face(t) = [[0,0,-ball_bearing_width(t)/2], [0,0,1], 0,0,0];


// Vitamin catalogue
module ball_bearing_Catalogue() {
    for (t = ball_bearing_types) ball_bearing(t);
}

// local color mapping
bearing_color = MetalColor;

module ball_bearing(type=BB624, ExplodeSpacing=10) {
    tn = type[3];
    vitamin("vitamins/ball_bearing.scad", str("Ball Bearing ",tn), str("ball_bearing(BB",tn,")")) {
        view(d=200);
    }

    rim = type[1] / 10;

    color(bearing_color) render() difference() {
        cylinder(r = type[1] / 2, h = type[2], center = true);
        cylinder(r = type[0] / 2, h = type[2] + 1, center = true);
        for(z = [-type[2] / 2, type[2] / 2])
            translate([0,0,z]) difference() {
                cylinder(r = (type[1] - rim) / 2, h = 2, center = true);
                cylinder(r = (type[0] + rim) / 2, 2, center = true);
            }
    }

    thread(type[2]/2, ExplodeSpacing=ExplodeSpacing)
        children();
}

module bearing_ball(dia) {
    //vitamin(str("SB",dia * 10,": Steel ball ",dia, "mm"));
    color(bearing_color) render() sphere(r = dia / 2);
}
