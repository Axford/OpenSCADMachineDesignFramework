/*
    Vitamin: V-Groove Bearing

    Modelled on:
    http://www.ebay.co.uk/itm/10x-20x-624VV-V-Groove-Sealed-Ball-Bearings-Vgroove-4-X-13-X-6mm-3mm-Deep-New-/221317556825?pt=LH_DefaultDomain_3&var=&hash=item33878dea59

    Local Frame:
        Centred at origin, lying on XY plane
*/


// Type getters
function VGrooveBearing_TypeSuffix(t)   = t[0];
function VGrooveBearing_Description(t)  = t[1];
function VGrooveBearing_OD(t)           = t[2];
function VGrooveBearing_ID(t)           = t[3];
function VGrooveBearing_Thickness(t)    = t[4];
function VGrooveBearing_GD(t)           = t[5];  // groove diameter

// Type table
//                      suffix,  description,                                   OD, ID, t, GD
VGrooveBearing_624VV = ["624VV", "624VV 4x13x6mm V Groove Sealed Ball Bearing", 13, 4,  6, 8];

// Type collection
VGrooveBearing_Types = [
    VGrooveBearing_624VV
];

// Vitamin catalogue
module VGrooveBearing_Catalogue() {
    for (t=VGrooveBearing_Types) VGrooveBearing(t);
}




// Connectors

VGrooveBearing_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module VGrooveBearing(type=VGrooveBearing_624VV, ExplodeSpacing=10) {

    ts = VGrooveBearing_TypeSuffix(type);
    desc = VGrooveBearing_Description(type);

    vitamin("vitamins/VGrooveBearing.scad", str(desc), str("VGrooveBearing(VGrooveBearing_",ts,")")) {
        view(r=[72,0,33], d=200);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(VGrooveBearing_Con_Def);
        }

        // parts
        VGrooveBearing_Model(type);
    }

    thread(VGrooveBearing_Thickness(type), ExplodeSpacing=ExplodeSpacing)
        children();
}

module VGrooveBearing_Model(t) {
    gd = VGrooveBearing_GD(t);
    od = VGrooveBearing_OD(t);
    id = VGrooveBearing_ID(t);
    t = VGrooveBearing_Thickness(t);

    $fn=32;

    color(MetalColor)
        render()
        difference() {
            union() {
                cylinder(r=od/2, h=1+eta);
                translate([0,0,1])
                    cylinder(r1=od/2, r2=gd/2, h=t/2-1+eta);
                translate([0,0,t/2])
                    cylinder(r1=gd/2, r2=od/2, h=t/2-1+eta);
                translate([0,0,t-1])
                    cylinder(r=od/2, h=1);
            }

            // bore
            cylinder(r=id/2, h=100, center=true);
        }

}
