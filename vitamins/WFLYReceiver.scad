/*

    Vitamin: WFly Receiver
    Modelled on WFR07S

    Authors:
        Damian Axford

    Local Frame:
        Corner of RX, front is y+, right is x+

*/


// Global Vars
WFLYReceiver_Width = 27.5;
WFLYReceiver_Length = 40.5;
WFLYReceiver_Height = 8.5;

// Connectors




module WFLYReceiver() {
    w = WFLYReceiver_Width;
    l = WFLYReceiver_Length;
    h = WFLYReceiver_Height;

    vitamin("vitamins/WFLYReceiver.scad", "WFLY Receiver", "WFLYReceiver()") {
        view(t=[23,9,3],r=[34,2,22],d=320);
    }

    if (DebugCoordinateFrames) frame();
    if (DebugConnectors) {


    }

    // body
    color(Grey20)
        cube([w,l,h]);

    // headers
    color(Grey20)
        translate()
        cube([24,9,11]);

    // antenna

}
