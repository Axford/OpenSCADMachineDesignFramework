//===================================== 
// This is public Domain Code
// Contributed by: William A Adams
// 14 May 2011
//=====================================

include <maths.scad>

//=========================================
//
// 			Functions
//
//=========================================

function parseSeg(seg) = [ 
	seg[0], 
	LineRotations(seg[1]-seg[0]), 
	VMAG(seg[1]-seg[0])
	];

function GetPlaneVectors(points) = [points[2]-points[1],points[0]-points[1]];

function quad_translate(quad, trans) = [ 
	VSUM(quad[0], trans), 
	VSUM(quad[1], trans),
	VSUM(quad[2], trans),
	VSUM(quad[3], trans)];

//=========================================
//
// 			Core Modules
//
//=========================================
module PlaceLine(seg, radius=0.025) 
{
	params = parseSeg(seg);

	origin = params[0];
	rot = params[1];
	len = params[2];

	translate(origin)
	rotate(rot)
	cylinder(r=radius, h=len);
}

module DisplayQuadFrame(quad, radius=0.125) 
{
	PlaceLine([quad[0], quad[1]], radius);
	PlaceLine([quad[1], quad[2]], radius);
	PlaceLine([quad[2], quad[3]], radius);
	PlaceLine([quad[3], quad[0]], radius);
}

// Display a polyhedron with some thickness 
module DisplayTriShard(shard)
{
	polyhedron(
		points=[
			shard[0][0], shard[0][1],shard[0][2], // Top
			shard[1][0], shard[1][1], shard[1][2]], // Bottom
		triangles=[
			[0,2,1],
			[3,4,5],
			[1,5,4],
			[1,2,5],
			[2,3,5],
			[2,0,3],
			[0,4,3],
			[0,1,4]
			]);
}

// Old style, complete single polyhedron for a quad shard
//	polyhedron(
//		points=[
//			outer[0], outer[1],outer[2], outer[3],	// Top
//			inner[0], inner[1], inner[2], inner[3]], 	// Bottom
//		triangles=[
//			[0,2,1],	// top
//			[0,3,2],	// top
//			[0,5,4],
//			[0,1,5],
//			[1,6,5],
//			[1,2,6],
//			[2,7,6],
//			[2,3,7],
//			[3,4,7],
//			[3,0,4],
//			[4,5,6],	// bottom
//			[4,6,7]
//			]);

module DisplayQuadShards( outer, inner,  edgefaces=[true, true, true, true] ) 
{
	// First put out the top and bottom
	polyhedron(
		points=[
			outer[0], outer[1],outer[2], outer[3],	// Top
			inner[0], inner[1], inner[2], inner[3]], 	// Bottom
		triangles=[
			[0,2,1],	// top
			[0,3,2],	// top
			[4,5,6],	// bottom
			[6,7,4]	// bottom
			]);


	// Now, only lay in the sides that are associated with outside faces, leaving
	// interior faces empty
	// ustep == 0
	if (edgefaces[0])
	{
		polyhedron(
			points=[
				outer[0], outer[1],outer[2], outer[3],	// Top
				inner[0], inner[1], inner[2], inner[3]], 	// Bottom
			triangles=[
				[0,5,4],
				[0,1,5],
				]);		
	}

	// v == 0
	if (edgefaces[1])
	{
		polyhedron(
			points=[
				outer[0], outer[1],outer[2], outer[3],	// Top
				inner[0], inner[1], inner[2], inner[3]], 	// Bottom
			triangles=[
				[1,6,5],
				[1,2,6],
				]);		
	}

	// u == 1
	if (edgefaces[2])
	{
		polyhedron(
			points=[
				outer[0], outer[1],outer[2], outer[3],	// Top
				inner[0], inner[1], inner[2], inner[3]], 	// Bottom
			triangles=[
				[2,7,6],
				[2,3,7],
				]);		
	}

	// v == 1
	if (edgefaces[3])
	{
		polyhedron(
			points=[
				outer[0], outer[1],outer[2], outer[3],	// Top
				inner[0], inner[1], inner[2], inner[3]], 	// Bottom
			triangles=[
				[3,4,7],
				[3,0,4],
				]);		
	}
}

module DisplayQuadNormals(quad, nlen, nradius=0.125)
{
	// Outward facing normal
	color([0,0,1])
	{
	PlaceLine([quad[0][0], quad[0][0]+(quad[1][0]*nlen)], radius=nradius);
	PlaceLine([quad[0][1], quad[0][1]+(quad[1][1]*nlen)], radius=nradius);
	PlaceLine([quad[0][2], quad[0][2]+(quad[1][2]*nlen)], radius=nradius);
	PlaceLine([quad[0][3], quad[0][3]+(quad[1][3]*nlen)], radius=nradius);
	}
	
	// Inner facing normal
	color([1,0,0])
	{
	PlaceLine([quad[0][0], quad[0][0]+(quad[1][0]*-nlen)], radius=nradius);
	PlaceLine([quad[0][1], quad[0][1]+(quad[1][1]*-nlen)], radius=nradius);
	PlaceLine([quad[0][2], quad[0][2]+(quad[1][2]*-nlen)], radius=nradius);
	PlaceLine([quad[0][3], quad[0][3]+(quad[1][3]*-nlen)], radius=nradius);
	}
}

//quad is an array of four points and an an array of four normals 
module DisplayQuadShard(quad, thickness=1, shownormals = false, edgefaces=[true, true, true, true]) 
{		
	inner = quad[0] + (quad[1]*thickness*-1);
	nradius = 0.125;
	nlen = thickness*Cphi;

	if (shownormals)
	{
		DisplayQuadNormals(quad, nlen);
	}
	
	//DisplayQuadFrame(quad[0]);
	//DisplayQuadFrame(inner);

	if( thickness < 0)
	{
		DisplayQuadShards(quad[0],quad[0] + quad[1]*thickness, edgefaces = edgefaces);
	}
	else
	{
		DisplayQuadShards(quad[0] + quad[1]*thickness,quad[0], edgefaces = edgefaces);
	}
}


//========================================
//
//		Bezier Display Routines
//
//========================================
module DisplayBezControlFrame(mesh, radius=0.125) 
{
	for (row=[0:2])
		for (column=[0:2])
		{
			color([0,1,1])
			DisplayQuadFrame(GetControlQuad(mesh, [row,column]), radius);
		}
}

module DisplayBezCurveFrame(mesh, 
	colors=[[1,1,0],[1,1,0],[1,1,0],[1,1,0]], 
	steps=4)
{
	for (ustep = [0:steps-1])
	{
		for (vstep=[0:steps-1])
		{
			assign(ufrac1 = ustep/steps)
			assign(ufrac2 = (ustep+1)/steps)
			assign(vfrac1=vstep/steps)
			assign(vfrac2=(vstep+1)/steps)
			assign(quad = GetCurveQuad(mesh, [ufrac1,vfrac1], [ufrac2,vfrac2]))
			{
				DisplayQuadFrame(quad);
			}
		}
	}
}

module linear_extrude_bezier(mesh, 
	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]], 
	steps=4, thickness=1, showControlFrame = false)
{
	if (showControlFrame)
		DisplayBezControlFrame(mesh);

	for (ustep = [0:steps-1])
	{
		for (vstep=[0:steps-1])
		{
			assign(ufrac1 = ustep/steps)
			assign(ufrac2 = (ustep+1)/steps)
			assign(vfrac1=vstep/steps)
			assign(vfrac2=(vstep+1)/steps)
			assign(outerquad = GetCurveQuad(mesh, [ufrac1,vfrac1], [ufrac2,vfrac2]))
			{
				assign(inner = quad_translate(outerquad, [0,0,-thickness]))

				color(berp(colors, vfrac1))
				DisplayQuadShards(outerquad, inner);
			}
		}
	}
}


module shell_extrude_bezier(mesh, 
	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]], 
	steps=4, thickness=1, 
	showControlFrame = false, 
	showNormals=false,
	showCurveFrame = false,
	opacity = 1)
{
	if (showControlFrame)
		DisplayBezControlFrame(mesh);

	if (showCurveFrame)
	{
		DisplayBezCurveFrame(mesh, steps=steps);
	} else
	{
		for (ustep = [0:steps-1])
		{
			for (vstep=[0:steps-1])
			{
				assign(ufrac1 = ustep/steps)
				assign(ufrac2 = (ustep+1)/steps)
				assign(vfrac1=vstep/steps)
				assign(vfrac2=(vstep+1)/steps)
				assign(quadandnorms = GetCurveQuadNormals(mesh, 
					[ufrac1,vfrac1], [ufrac2,vfrac2]))
				assign(lcolor = berp(colors, vfrac1))
				{
					color([lcolor[0], lcolor[1], lcolor[2], opacity])
					DisplayQuadShard(quadandnorms, 
						thickness, 
						shownormals =showNormals,
						edgefaces=[ustep==0, vstep==0, ustep==steps-1, vstep==steps-1]);
				}
			}
		}
	}
}

//========================================
//
//		Experimental Display Routines
//
//========================================
// This function will extrude a bezier solid from a bezier curve 
// It is a straight up prism
// c - ControlPoints
//
module BezFillet(c, focalPoint, 
	steps = 18, 
	height = 1,
	colors = [[1,0,0],[1,1,0],[0,1,1],[0,0,1]])
{
	for(step = [steps:1])
	{
//echo(PtOnBez(colors, step/steps));
		color(berp(colors, step/steps))
		linear_extrude(height = height, convexity = 3) 
		polygon(
			points=[
				focalPoint,
				PtOnBez2D(c[0], c[1], c[2],c[3], step/steps),
				PtOnBez2D(c[0], c[1], c[2],c[3], (step-1)/steps)],
			paths=[[0,1,2]]
		);
	}
}


//
// Name: BezRibbon
//
// Params:
//	c1 - First set of control points
//	c2 - Second set of control points
//	steps - Number of steps to evaluate along the curve
//	height - How thick the ribbon should be
//	colors - A bezier curve representing the color ramp
//
module linear_extrude_bez_ribbon(c1, c2, 
	steps=18, 
	height=1, 
	colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]])
{
	for (step=[0:steps-1])
	{
		color(PtOnBez(colors, step/steps))
		linear_extrude(height = height, convexity = 10) 
		polygon(
			points=[
			PtOnBez2D(c1[0], c1[1], c1[2],c1[3], step/steps),
			PtOnBez2D(c2[0], c2[1], c2[2],c2[3], (step)/steps),
			PtOnBez2D(c2[0], c2[1], c2[2],c2[3], (step+1)/steps),
			PtOnBez2D(c1[0], c1[1], c1[2],c1[3], (step+1)/steps)],
			paths=[[0,1,2,3]]
			);

	}
}

module BezCubicRibbonRotate(c1, c2, steps=gSteps, height=gHeight, colors=[[1,0,0],[1,1,0],[0,1,1],[0,0,1]])
{
	for (step=[0:steps-1])
	{
		color(berp(colors, step/steps))
		rotate_extrude(convexity=3) 
		polygon(
			points=[
				PtOnBez2D(c1[0], c1[1], c1[2],c1[3], step/steps),
				PtOnBez2D(c2[0], c2[1], c2[2],c2[3], (step)/steps),
				PtOnBez2D(c2[0], c2[1], c2[2],c2[3], (step+1)/steps),
				PtOnBez2D(c1[0], c1[1], c1[2],c1[3], (step+1)/steps)],
		paths=[[0,1,2,3]]
		);
	}
}



module DisplayMeshControlFrame(mesh, radius=0.125) 
{
	for (row=[0:2])
		for (column=[0:2])
		{
			color([0,1,1])
			DisplayQuadFrame(GetControlQuad(mesh, [row,column]), radius);
		}
}

module bezierMeshSolid(mesh,
	colors=[[1,1,0],[1,1,0],[1,1,],[1,1,0]], 
	granuleSize = [1,1,1], 
	usteps=100, vsteps=100)
{
	for (ustep = [0:usteps])
	{
		for(vstep=[0:vsteps])
		{
			assign(ufrac = ustep/usteps)
			assign(vfrac = vstep/vsteps)
			assign(vpt = PtOnBezMesh(mesh, [ufrac,vfrac]))
			{
				//echo(vpt);
				translate([vpt[0], vpt[1], vpt[2]])
				cube(size=[1,1,vpt[2]]);
			}
		}
	}
}


