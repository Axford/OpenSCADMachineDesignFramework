/*

    Vitamin: APM 2.5


    Authors:
        Damian Axford

    Local Frame:
        Corner of PCB, front is y+, right is x+

*/


// Global Vars
APM25_Width = 40.64;
APM25_Length = 66.42;


// Connectors
APM25_BottomLeftMount = [[5.33/2, 5.33/2, 0], [0,0,-1], 0,0,0];
APM25_Center =          [[APM25_Width/2, APM25_Length/2, 0], [0,0,-1], 0,0,0];


module APM25_Fixings2D(r=3.5/2, h=100) {
    w = APM25_Width;
    d = APM25_Length;
    t = 1.7;

    fd = 3.5;  // fixing diameter
    fi = 5.33/2;  // fixing inset

    // fixings
    for (x=[0,1], y=[0,1])
        translate([fi + x*(w-2*fi), fi + y*(d-2*fi), 0])
        circle(r=r);
}

module APM25_Fixings(r=3.5/2, h=100) {
    linear_extrude(100, center=true)
        APM25_Fixings2D(r,h);
}


module APM25() {
    w = APM25_Width;
    d = APM25_Length;
    t = 1.7;

    fd = 3.3;  // fixing diameter
    fi = 5.33/2;  // fixing inset

    vitamin("vitamins/APM25.scad", "APM 2.5", "APM25()") {
        view(d=300);
    }

    if (DebugCoordinateFrames) frame();
    if (DebugConnectors) {
        connector(APM25_BottomLeftMount);
        connector(APM25_Center);

    }

    // PCB, with fixing holes
    color([0.7,0,1])
        difference() {
            roundedCube([w,d,t],1);

            APM25_Fixings();
        }


    // In headers

    // Out headers

    // USB

    // GPS

    // other

}
