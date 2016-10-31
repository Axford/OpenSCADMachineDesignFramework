/*
    Vitamin: ${description}

    Local Frame:
*/


// Connectors

${name}_Con_Def				= [ [0,0,0], [0,0,-1], 0, 0, 0];



module ${name}() {

    vitamin("vitamins/${name}.scad", "${description}", "${name}()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(${name}_Con_Def);
        }

        // parts
        ${name}_Body();
    }
}

module ${name}_Body() {
    part("${name}_Body", "${name}_Body()");

    color(Blue, 0.8)
        if (UseVitaminSTL) {
            import(str(VitaminSTL,"${name}_Body.stl"));
        }
        else
        {
            // body
            cube([10,10,10]);

        }
}
