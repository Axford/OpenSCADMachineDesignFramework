
module ${name}Assembly () {

    assembly("assemblies/${name}.scad", "${description}", str("${name}Assembly()")) {

        // base part

        // steps
        step(1, "Do something") {
            view(t=[0,0,0], r=[52,0,218], d=400);

            //attach(DefConDown, DefConDown)
            //      AnotherAssembly();
        }



    }
}
