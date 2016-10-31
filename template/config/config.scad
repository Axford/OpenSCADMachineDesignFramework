//
// Config
//

// Coding-style
// ------------
//
// Global variables are written in UpperCamelCase.
// A logical hierarchy should be indicated using underscores, for example:
//     StepperMotor_Connections_Axle
//
// Global short-hand references should be kept to a minimum to avoid name-collisions

// Framework configuration
include <../framework/config/config.scad>


// Put overrides to framework config here
ColourScheme = 2;


// Machine specific global parameters here
// common wall thicknesses for printed parts
DefaultWall 	= 4*perim;
ThickWall 		= 8*perim;
// short-hand
dw 				= DefaultWall;
tw 				= ThickWall;

// Global design parameters




// Include all other project specific configuration files
include <utils.scad>
include <vitamins.scad>
include <cutparts.scad>
include <printedparts.scad>
include <assemblies.scad>
