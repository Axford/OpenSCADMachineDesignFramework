//===================================== 
// This is public Domain Code
// Contributed by: William A Adams
// 25 May 2011
//=====================================

include <Renderer.scad>


outer = [[0,10,10],[0,0,10],[10,0,10],[10,10,10]];
inner = [[0,10,0],[0,0,0],[10,0,0],[10,10,0]];

//DisplayQuadShards(outer, inner);

*tubular(OR=24, 
	steps=8, 
	showNormals=false, 
	showControlFrame=false, 
	showCurveFrame=false,
	opacity = 0.75);


cp1 = [[-25, -30,0], [-10, 20,0], [10,20,0], [25,-30,0]];
cp2 = [[-15, -25,7], [-7, 15,0], [7,15,0], [15,-25,7]];
cp3 = [[-15, -25,15], [-7, 15,0], [7,15,0], [15,-25,15]];
cp4 = [[-25, -30,25], [-10, 20,0], [10,20,0], [25,-30,25]];

gcp1 = [[0,0,0], [1,-1,0], [2,-1,0], [2.5,0.5,0]]; 
gcp2 = [[0,1,1], [1,1,2], [2,1,2], [3,1,1]]; 
gcp3 = [[0,2,1], [1,2,2], [2,2,2], [3,2,1]]; 
gcp4 = [[0,3,0], [1,4,0], [2,4,0], [3,3,0]]; 

fcp1 = [[0,0,0], [10,0,0], [20,0,0], [30,0,0]]; 
fcp2 = [[0,10,0], [10,10,0], [20,10,0], [30,10,0]]; 
fcp3 = [[0,20,0], [10,20,0], [20,20,0], [30,20,0]]; 
fcp4 = [[0,30,10], [10,30,10], [20,30,10], [30,30,10]]; 

tcp4 = [[0,0,0], [0,0,25], [0,25,25], [0,25,50]]; 
tcp3 = [[25,0,0], [25,0,25], [25,25,25], [25,25,50]]; 
tcp2 = [[50,25,0], [50,25,25], [25,25,25], [25,25,50]]; 
tcp1 = [[50,50,0], [50,50,25], [25,50,25], [25,50,50]]; 

ttcp4 = [[0,25,50], [25,25,50], [25,25,50], [25,50,50]]; 
ttcp3 = [[0,25,25], [25,25,25], [25,25,25], [25,50,25]]; 
ttcp2 = [[0,0,25], [25,0,25], [25,25,25], [50,25,25]]; 
ttcp1 = [[0,0,0], [25,0,0], [25,25,0], [50,25,0]]; 

// Half of a tube with opening pointing towards -x
otcp1 = [[0,25,0], [25,25,0], [25,25,25], [0,25,25]]; 
otcp2 = [[0,16,0], [25,16,0], [25,16,25], [0,16,25]]; 
otcp3 = [[0,8,0], [25,8,0], [25,8,25], [0,8,25]]; 
otcp4 = [[0,0,0], [25,0,0], [25,0,25], [0,0,25]]; 



// This one does not do so well because it is 'vertical', so it folds
// on itself when doing a z-axis extrusion
// It cam be easily improved by laying out the vertices such that
// the z-axis extrusion is more clear
*linear_extrude_bezier([cp1,cp2,cp3,cp4], 
	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
	steps=16, thickness=2);


//This one does fine as it is mostly 'flat' with respect to the 
// x-y plane
//linear_extrude_bezier([gcp1,gcp2,gcp3,gcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=8, thickness = 0.25);


//shell_extrude_bezier([gcp1,gcp2,gcp3,gcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=4, thickness=0.25);

//shell_extrude_bezier([cp1,cp2,cp3,cp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=3, thickness=4);

//shell_extrude_bezier([fcp1,fcp2,fcp3,fcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=6, thickness=-4);

//shell_extrude_bezier([tcp1,tcp2,tcp3,tcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=6, thickness=-4,
//	showControlFrame = true,
//	showNormals = true);

//shell_extrude_bezier([ttcp1,ttcp2,ttcp3,ttcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=6, thickness=-2,
//	showControlFrame = true,
//	showNormals = true);

//shell_extrude_bezier([otcp1,otcp2,otcp3,otcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=18, thickness=-2,
//	showControlFrame = true,
//	showNormals = true);

//shell_extrude_bezier([elbcp1,elbcp2,elbcp3,elbcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=8, thickness=-2,
//	showControlFrame = true,
//	showNormals = true);


module tubular(OR, steps=3, 
	showNormals=false, 
	showControlFrame = false, 
	showCurveFrame=false, 
	opacity =1)
{

	xoffset=OR;
	yoffset = OR*sin(30);
	//echo("OFFSET: ", xoffset, yoffset);

	elbcp1 = [[0,OR,-12], [0,0,-12], [0,0,12], [0,OR,12]]; 
	elbcp2 = [[-yoffset,xoffset,-12], [0,0,-12], [0,0,12], [-yoffset,xoffset,12]]; 
	elbcp3 = [[-xoffset,yoffset,-12], [0,0,-12], [0,0,12], [-xoffset,yoffset,12]]; 
	elbcp4 = [[-OR,0,-12], [0,0,-12], [0,0,12], [-OR,0,12]]; 

	shell_extrude_bezier([elbcp1,elbcp2,elbcp3,elbcp4], 
		colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
		steps=steps, 
		thickness=-2,
		showControlFrame =showControlFrame,
		showNormals = showNormals,
		showCurveFrame=showCurveFrame,
		opacity = opacity);

//	translate([0, -OR,0])
//	rotate([0,0,90])
//shell_extrude_bezier([elbcp1,elbcp2,elbcp3,elbcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=steps, thickness=-2,
//	showControlFrame =showControlFrame,
//	showNormals = showNormals);


//	rotate([0,0,180])
//shell_extrude_bezier([elbcp1,elbcp2,elbcp3,elbcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=steps, thickness=-2,
//	showControlFrame =showControlFrame,
//	showNormals = showNormals);
//
//	rotate([0,0,270])
//shell_extrude_bezier([elbcp1,elbcp2,elbcp3,elbcp4], 
//	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]],
//	steps=steps, thickness=-2,
//	showControlFrame = showControlFrame,
//	showNormals = showNormals);

}
