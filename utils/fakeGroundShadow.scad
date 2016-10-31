

module FakeGroundShadow(numberOfLayers=5, refColor=[0.8,0.8,0.8], spread=0.01) {
    children();
    
    for (i=[-numberOfLayers/2 : numberOfLayers/2])
        assign($ShowBOM=false) // turn off BOM for fake shadow children!
        color([refColor[0] - i*0.05, refColor[1] - i*0.05, refColor[2] - i*0.05])
        translate([0, 0, i*.01])
        scale([1 - i*spread, 1 - i*spread, 0.001])
        children();
}