//
// Colors
//


// Coding-style
// ------------
//
// Colors are global variables, and are therefore written in UpperCamelCase.
//
// Generic colors should use their normal descriptive name for the variable name.
// Material-specific colours should have a Color suffix


// Generic Colors
// =======================

White							= [1,1,1];
Blue							= [0, 0, 1];
Brass                           = "gold";
Grey20                          = [0.2, 0.2, 0.2];
Grey50                          = [0.5, 0.5, 0.5];
Grey60							= [0.6, 0.6, 0.6];
Grey70                          = [0.7, 0.7, 0.7];
Grey80                          = [0.8, 0.8, 0.8];
Grey90                          = [0.9, 0.9, 0.9];

// Material Colors
// ===============

AluColor  						= Grey70;
AluminiumColor                  = AluColor;
MetalColor						= Grey60;
BeltColor 						= "white";
PolycarbonateColor 			 	= [1,0.8,0.5,0.5];
SiliconeColor 					= [1,0.8,0.8,0.8];
WoodColor 						= "orange";

PlasticColor 					= "orange";

// Additional Plastic colours to differentiate sub-assemblies

ColourScheme = 1;

ColourSchemes = [
    [[1, 0.5, 0],     [1, 0.6, 0.2]],   // 0 = Axford
    [[0.2, 0.5, 0.2], [0.3, 0.9, 0.3], [0.4, 0.5, 0.4]],    //  1 = Gyrobot
    [[0.6, 0.5, 0.4],     [0.7, 0.6, 0.5]]     // 2 = subdued
];

Level2PlasticColor				= ColourSchemes[ColourScheme][0];
Level3PlasticColor 				= ColourSchemes[ColourScheme][1];
Level4PlasticColor 				= ColourSchemes[ColourScheme][2];

// Material Color aliases
// For compatibility with 3rd party libraries
//

hard_washer_color				 = Grey50;
screw_cap_color 				 = Grey20;
nut_color						 = Grey50;
