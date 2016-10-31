/*
    Vitamin: Igus Drylin N Rail


    Reference:     http://www.igus.co.uk/iProsvc/Download.aspx?File=P02570900GBen.pdf&Name=drylin%c2%ae%2520N%2520NS-01-27.pdf

    Local Frame:
        Extruded along Z+
        Width of rail is in X axis, centred
        Base of rail at y=0, extends along y+
*/



// Type getters
function IgusDrylinNRail_TypeSuffix(t)  = t[0];
function IgusDrylinNRail_Description(t) = t[1];
function IgusDrylinNRail_A(t)           = t[2];
function IgusDrylinNRail_C4(t)          = t[3];
function IgusDrylinNRail_A3(t)          = t[4];
function IgusDrylinNRail_C5(t)          = t[5];
function IgusDrylinNRail_H(t)           = t[6];
function IgusDrylinNRail_H1(t)          = t[7];
function IgusDrylinNRail_K1(t)          = t[8];

// Type table
//                        suffix    description, a,  C4, A3, C5, h, h1,  k1
IgusDrylinNRail_NS0127 = ["NS0127", "NS-01-17",  27, 60, 0,  20, 9, 1.1, 4];


// Type collection
IgusDrylinNRail_Types = [
    IgusDrylinNRail_NS0127
];

// Vitamin Catalogue
module IgusDrylinNRail_Catalogue() {
    for (t=IgusDrylinNRail_Types) IgusDrylinNRail(t);
}



// Connectors

IgusDrylinNRail_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];

// Carriage fixing places carriage at the end of the rail
function IgusDrylinNRail_Con_Carriage(t)		= [ [0, IgusDrylinNRail_H(t)/2, 0], [0,0,1], 0, 0, 0];

// Fixings
function IgusDrylinNRail_Con_Fixings(t, num)		= [ [0, IgusDrylinNRail_H1(t), IgusDrylinNRail_C5(t) + num*IgusDrylinNRail_C4(t)], [0,-1,0], 0, 0, 0];

module IgusDrylinNRail(type=IgusDrylinNRail_NS0127, length=100) {

    ts = IgusDrylinNRail_TypeSuffix(type);
    desc = IgusDrylinNRail_Description(type);

    vitamin("vitamins/IgusDrylinNRail.scad", str("Igus Drylin N Rail ",desc, " ",length,"mm"), str("IgusDrylinNRail(IgusDrylinNRail_",ts,", length=",length,")")) {
        view(t=[-12,20,25], r=[150,330,180], d=250);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(IgusDrylinNRail_Con_Def);
            connector(IgusDrylinNRail_Con_Carriage(type));
        }

        // parts
        IgusDrylinNRail_Model(type, length);
    }
}

module IgusDrylinNRail_Model(t, l) {
    a = IgusDrylinNRail_A(t);
    c4 = IgusDrylinNRail_C4(t);
    a3 = IgusDrylinNRail_A3(t);
    c5 = IgusDrylinNRail_C5(t);
    h = IgusDrylinNRail_H(t);
    h1 = IgusDrylinNRail_H1(t);
    k1 = IgusDrylinNRail_K1(t);

    wall = 2; // guess

    ts = IgusDrylinNRail_TypeSuffix(t);
    desc = IgusDrylinNRail_Description(t);

    stlName = str("IgusDrylinNRail",ts, l,"mm");

    callStr = str("IgusDrylinNRail_Model(IgusDrylinNRail_",ts,",",l,")");

    part(stlName, callStr);

    color([0.8,0.8,0.8])
        if (UseVitaminSTL) {
            import(str(VitaminSTL,str(stlName,".stl")));
        }
        else
        {
            render()
            difference() {
                // Rail profile
                linear_extrude(l)
                    union()
                    for (x=[0,1])
                        mirror([x,0,0]) {
                            // base
                            translate([-1,0,0])
                                square([a/2-wall+1, h1]);

                            // stub
                            translate([10/2,0,0])
                                square([wall, h/2]);

                            // bottom of channel
                            translate([10/2, h/2-wall, 0])
                                square([a/2 - 10/2, wall]);

                            // side
                            translate([a/2-wall, h/2-wall])
                                square([wall, h/2+wall]);

                            // top of channel
                            translate([a/2-4, h-1, 0])
                                square([4, 1]);

                        }

                // Fixings
                for (i=[0:round(l/c4)])
                    translate([0,0, c5 + i*c4])
                    rotate([90,0,0])
                    cylinder(r=k1/2, h=100, center=true);
            }
    }
}
