/*
    Vitamin: Igus Drylin N Carriage


    Reference:     http://www.igus.co.uk/iProsvc/Download.aspx?File=P02570900GBen.pdf&Name=drylin%c2%ae%2520N%2520NS-01-27.pdf

    Local Frame:
        Extruded along Z+
        Width of Carriage is in X axis, centred
        Base of Carriage at y=0, extends along y+
*/

// Global parameters
DrylinColor = [0.9, 0.85, 0.6];


// Type getters
function IgusDrylinNCarriage_TypeSuffix(t)  = t[0];
function IgusDrylinNCarriage_Description(t) = t[1];
function IgusDrylinNCarriage_A(t)           = t[2];   // little a on datasheet, rail outer width
function IgusDrylinNCarriage_C4(t)          = t[3];
function IgusDrylinNCarriage_A3(t)          = t[4];
function IgusDrylinNCarriage_C5(t)          = t[5];
function IgusDrylinNCarriage_H(t)           = t[6];  // little h on datasheet
function IgusDrylinNCarriage_H1(t)          = t[7];
function IgusDrylinNCarriage_K1(t)          = t[8];
function IgusDrylinNCarriage_Preload(t)     = t[9];   // 0=no, 1=yes
function IgusDrylinNCarriage_AA(t)          = t[10];  // capital A on datasheet, carriage width
function IgusDrylinNCarriage_C(t)           = t[11];
function IgusDrylinNCarriage_C1(t)          = t[12];
function IgusDrylinNCarriage_C2(t)          = t[13];
function IgusDrylinNCarriage_K23(t)         = t[14];  // K2 or K3
function IgusDrylinNCarriage_HH(t)          = t[15];  // capital H on datasheet
function IgusDrylinNCarriage_SP(t)          = t[16];
function IgusDrylinNCarriage_DP(t)          = t[17];

// Type table
//                               suffix        description,    A,  C4, A3, C5, h, h1,  k1, p  AA,  C,  C1, C2, K2/3, HH,  SP, DP,
IgusDrylinNCarriage_NW222760P = ["NW222760P", "NW-22-27-60P",  27, 60, 0,  20, 9, 1.1, 4,  1, 9.5, 60, 60, 20, 4,    9.5, 5,  6.5];


// Type collection
IgusDrylinNCarriage_Types = [
    IgusDrylinNCarriage_NW222760P
];

// Vitamin Catalogue
module IgusDrylinNCarriage_Catalogue() {
    for (t=IgusDrylinNCarriage_Types) IgusDrylinNCarriage(t);
}



// Connectors

// Default fixing is at origin
IgusDrylinNCarriage_Con_Def				         = [ [0,0,0], [0,0,1], 0, 0, 0];

// Face connector is on upper surface, centered in the middle of the carriage
function IgusDrylinNCarriage_Con_Face(t)		 = [ [0,IgusDrylinNCarriage_HH(t) - IgusDrylinNCarriage_H(t)/2, IgusDrylinNCarriage_C1(t)/2], [0,-1,0], 0, 0, 0];

// Fixing connector, pass type and fixing number (0, 1)
function IgusDrylinNCarriage_Con_Fixings(t, num) = [ [0,IgusDrylinNCarriage_HH(t) - IgusDrylinNCarriage_H(t)/2+ IgusDrylinNCarriage_SP(t), (IgusDrylinNCarriage_C(t) - IgusDrylinNCarriage_C2(t))/2 + num*IgusDrylinNCarriage_C2(t)], [0,-1,0], 0, 0, 0];


module IgusDrylinNCarriage(type=IgusDrylinNCarriage_NW222760P) {

    ts = IgusDrylinNCarriage_TypeSuffix(type);
    desc = IgusDrylinNCarriage_Description(type);

    vitamin("vitamins/IgusDrylinNCarriage.scad", str("Igus Drylin N Carriage ",desc), str("IgusDrylinNCarriage(IgusDrylinNCarriage_",ts,")")) {
        view(t=[-12,20,25], r=[150,330,180], d=250);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(IgusDrylinNCarriage_Con_Def);
            connector(IgusDrylinNCarriage_Con_Face(type));
            connector(IgusDrylinNCarriage_Con_Fixings(type,0));
            connector(IgusDrylinNCarriage_Con_Fixings(type,1));
        }

        // parts
        IgusDrylinNCarriage_Model(type);
    }
}

module IgusDrylinNCarriage_Model(t) {
    a = IgusDrylinNCarriage_A(t);
    c4 = IgusDrylinNCarriage_C4(t);
    a3 = IgusDrylinNCarriage_A3(t);
    c5 = IgusDrylinNCarriage_C5(t);
    h = IgusDrylinNCarriage_H(t);
    h1 = IgusDrylinNCarriage_H1(t);
    k1 = IgusDrylinNCarriage_K1(t);
    p = IgusDrylinNCarriage_Preload(t);
    aa = IgusDrylinNCarriage_AA(t);
    c = IgusDrylinNCarriage_C(t);
    c1 = IgusDrylinNCarriage_C1(t);
    c2 = IgusDrylinNCarriage_C2(t);
    k23 = IgusDrylinNCarriage_K23(t);
    hh = IgusDrylinNCarriage_HH(t);
    sp = IgusDrylinNCarriage_SP(t);
    dp = IgusDrylinNCarriage_DP(t);

    wall = 2; // guess

    color(DrylinColor)
        render()
        difference() {
            union() {
                // Carriage profile
                linear_extrude(c1)
                for (x=[0,1])
                    mirror([x,0,0])
                    union() {
                        // base
                        translate([2,0,0])
                            square([a/2 - wall-2, h/2-1]);

                        // stub
                        translate([0,0,0])
                            square([aa/2, h/2 + hh-h]);
                    }

                // fixing posts
                if (p > 0) {
                    for (i=[0,1])
                        translate([0,0, (c-c2)/2 + i*c2])
                        rotate([-90,0,0])
                        cylinder(r=dp/2, h=h/2 + hh-h + sp);
                }
            }


            // Fixings
            for (i=[0,1])
                translate([0,0, (c-c2)/2 + i*c2])
                rotate([90,0,0])
                cylinder(r=k1/2, h=100, center=true);
        }

}
