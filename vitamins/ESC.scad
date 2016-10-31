
// Modelled on a generic 30A ESC

ESC_Length = 55;
ESC_Width = 25;
ESC_Height = 9;

Con_ESC_CenterBottom = [ [ESC_Width/2, ESC_Length/2, 0], [0, 0, -1], 0, 0, 0 ];


module ESC()
{
    vitamin("vitamins/ESC.scad", "ESC", "ESC()") {
        view(d=300);
    }

    if (DebugCoordinateFrames)  frame();
    if (DebugConnectors) {
        connector(Con_ESC_CenterBottom);
    }

    c = 2;

    color("blue")
        roundedRectX([ESC_Width, ESC_Length, ESC_Height], 2);

    // leads
    color("red")
        translate([ESC_Width-4,ESC_Length,ESC_Height/2])
        rotate([-90,0,0])
        cylinder(r=4/2, h=50);
}
