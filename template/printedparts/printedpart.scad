// Connectors

${name}_Con_Def = [[0,0,0], [0,0,-1], 0,0,0];


module ${name}_STL() {

    printedPart("printedparts/${name}.scad", "${description}", "${name}_STL()") {

        view(t=[0,0,0],r=[72,0,130],d=400);

        if (DebugCoordinateFrames) frame();
        if (DebugConnectors) {
            connector(${name}_Con_Def);
        }

        color(Level3PlasticColor) {
            if (UseSTL) {
                import(str(STLPath, "${name}.stl"));
            } else {
                ${name}_Model();
            }
        }
    }
}


module ${name}_Model()
{
    // local vars

    // model
    difference() {
        union() {
            cube([10,10,10]);
        }


    }
}
