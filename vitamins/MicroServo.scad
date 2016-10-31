/*
	Vitamin: MicroServo
	Model of a simple 9g micro servo.
	
	Derived from a thingiverse model by holgero - see http://www.thingiverse.com/thing:65081/#files
	
	Authors:
		holgero, Damian Axford
	
	Local Frame: 
		Bottom corner at the origin
	
	Parameters:
		None
		
	Returns:
		A Micro Servo model, colored
*/


// Connectors

// Connector: MicroServo_Con_Horn
// Positioned at base of contro horn spline - see <MicroServo>
MicroServo_Con_Horn				= [ [6.3, 6.3, 26.5], [0,0,1], 0, 0, 0];

// Connector: MicroServo_Con_Fixing1
// Positioned at x- fixing point - see <MicroServo>
MicroServo_Con_Fixing1			= [ [2.65 - 4.65, 6.3, 16.3 + 2], [0,0,-1], 0, 2, 2];

// Connector: MicroServo_Con_Fixing2
// Positioned at x+ fixing point - see <MicroServo>
MicroServo_Con_Fixing2			= [ [32.8-2.65 - 4.65, 6.3, 16.3 + 2], [0,0,-1], 0, 2, 2];



module MicroServo() {

    vitamin("vitamins/MicroServo.scad", "9g Micro Servo", "MicroServo()") {
        view(t=[6.9, 13.6, 10.3], r=[72,0,33], d=280);

        if (DebugCoordinateFrames) {
            frame();
        }

        if (DebugConnectors) {
            connector(MicroServo_Con_Horn);
            connector(MicroServo_Con_Fixing1);
            connector(MicroServo_Con_Fixing2);
        }
        
        // parts
        MicroServo_Body();
        MicroServo_Spline();
	}
}

module MicroServo_Body() {
    part("MicroServo_Body", "MicroServo_Body()");

    color(Blue, 0.8) 
        if (UseVitaminSTL) {
            import(str(VitaminSTL,"MicroServo_Body.stl"));
        } 
        else 
        {
            // body - bottom
            cube([23.5,12.6,16.4]);
        
            // body - mounting flange
            translate([-4.65,0,16.3]) difference() {
                cube([32.8,12.6,2]);
            
                // fixing holes
                translate([2.65,6.3,-0.1]) cylinder(r=1,h=3,$fn=45);
                translate([32.8-2.65,6.3,-0.1]) cylinder(r=1,h=3,$fn=45);
            }
    
            // body - top
            translate([0,0,18.2]) cube([23.5,12.6,4.4]);
    
            // body very top
            translate([6.3,6.3,22.5]) cylinder(r=6.3,h=4.1,$fn=45);
        }
}

module MicroServo_Spline() {
    part("MicroServo_Spline", "MicroServo_Spline()");

    color(White, 0.8) 
        if (UseVitaminSTL) {
            import(str(VitaminSTL,"MicroServo_Spline.stl"));
        } 
        else 
        {
            translate([6.3,6.3,26.5]) cylinder(r=2.25,h=2.8,$fn=45);
        }
}
