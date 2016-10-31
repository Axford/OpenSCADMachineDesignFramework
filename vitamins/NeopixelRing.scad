
// Modelled on Adafruit Neopixel 16
// TODO: Parameterise this for the different ring sizes


NeopixelRing_OD = 44.5;
NeopixelRing_ID = 31.75;

module NeopixelRing()
{
    vitamin("vitamins/NeopixelRing.scad", "Neopixel Ring 16", "NeopixelRing()") {
        view(t=[23,9,3],r=[34,2,22],d=320);
    }

    if (DebugCoordinateFrames) frame();
    if (DebugConnectors) {


    }

    color("black")
        tube(44.5/2, 31.75/2, 1);

    // LEDS
    color("white")
        for (i=[0:15])
        rotate([0,0,i*360/16])
        translate([-5.5/2,32.5/2,1])
        cube([5.5,5.5,1.5]);
}
