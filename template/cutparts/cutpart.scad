/*
    Cutpart: ${description}

    Local Frame:
*/


// Connectors

${name}_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module ${name}(complete=false) {

    if (DebugCoordinateFrames) frame();
    if (DebugConnectors) {
        connector(${name}_Con_Def);
    }

    cutPart(
        "cutparts/${name}.scad",
        "${description}",
        "${name}()",  // call to use to show a particular step
        "${name}(true)",  // call to use to show final part
        3,   // how many steps
        complete  // show as complete?  i.e. last step!
        ) {

        // Most cut parts use a difference...
        difference() {
            step(1, "Start with a block of something") {
                view();

                cube([10, 10, 10]);
            }

            step(2, "Drill a 4mm hole through the middle") {
                view();

                cylinder(r=2, h=100, center=true);
            }

            step(3, "Countersink the hole") {
                view();

                translate([0,0,3])
                    cylinder(r1=2, r2=5, h=3);
            }

            // Put further processing steps below, e.g. more cuts, drilling holes

        }

    }
}
