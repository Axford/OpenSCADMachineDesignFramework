include <config/config.scad>

STLPath = "printedparts/stl/";
VitaminSTL = "framework/vitamins/stl/";

DebugCoordinateFrames = 0;
DebugConnectors = false;

UseSTL = true;

machine("${name}.scad","${name}") {

    view(size=[1024,768], t=[68, 49, -37], r=[73, 0, 229], d=1951);


    //Top level assembly
    //Assembly();

    // dummy cube - just so you can see something!
    cube([10,10,10]);

    // NB: use the adda.py utility script to create new assemblies:
    //     framework/scripts/adda.py assembly <assembly name> <assembly description>
}
