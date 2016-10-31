//===================================== 
// This is public Domain Code
// Contributed by: William A Adams
// May 2011
//=====================================

/*
	A set of math routines for graphics calculations

	There are many sources to draw from to create the various math
	routines required to support a graphics library.  The routines here
	were created from scratch, not borrowed from any particular 
	library already in existance.

	One great source for inspiration is the book:
		Geometric Modeling
		Author: Michael E. Mortenson

	This book has many great explanations about the hows and whys
	of geometry as it applies to modeling.

	As this file may accumulate quite a lot of routines, you can either
	include it whole in your OpenScad files, or you can choose to 
	copy/paste portions that are relevant to your particular situation.

	It is public domain code, simply to avoid any licensing issues.
*/

//=======================================
//				Constants
//=======================================
// The golden mean 
Cphi = 1.61803399;

// PI
Cpi = 3.14159;
Ctau = Cpi*2;

//=======================================
//
// 		        General Routines
//
//=======================================

// map v from range r1 to range r2
function map(v, r1, r2) = (r2[1]-r2[0]) * (v - r1[0]) / (r1[1] - r1[0]) + r2[0];


//=======================================
//
// 				Point Routines
//
//=======================================

// Create a point
function Point2D_Create(u,v) = [u,v]; 
function Point3D_Create(u,v,w) = [u,v,w];

//=======================================
//
// 				Vector Routines
//
//=======================================

// Basic vector routines
// Sum of two vectors
function VSUM(v1, v2) = [v1[0]+v2[0], v1[1]+v2[1], v1[2]+v2[2]];
function VSUB(v1, v2) = [v1[0]-v2[0], v1[1]-v2[1], v1[2]-v2[2]];

function VMULT(v1, v2) = [v1[0]*v2[0], v1[1]*v2[1], v1[2]*v2[2]];

// Magnitude of a vector
// Gives the Euclidean norm
function VLENSQR(v) = (v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
function VLEN(v) = sqrt(VLENSQR(v));
function VMAG(v) = sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);


// Returns the unit vector associated with a vector
function VUNIT(v) = v/VMAG(v);
function VNORM(v) = v/VMAG(v);

// The scalar, or 'dot' product
// law of cosines
// if VDOT(v1,v2) == 0, they are perpendicular
function SPROD(v1,v2) = v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2];
function VDOT(v1v2) = SPROD(v1v2[0], v1v2[1]);

// The vector, or Cross product
// Given an array that contains two vectors
function VPROD(vs) = [
	(vs[0][1]*vs[1][2])-(vs[1][1]*vs[0][2]), 
	(vs[0][2]*vs[1][0])-(vs[1][2]*vs[0][0]),
	(vs[0][0]*vs[1][1])-(vs[1][0]*vs[0][1])];
function VCROSS(v1, v2) = VPROD([v1,v2]);

// Calculate the angle between two vectors
function VANG(v1, v2) = acos(VDOT([v1,v2])/(VMAG(v1)*VMAG(v2)));

// Calculate the rotations necessary to take a polygon, and apply 
// the rotate() transform, and get the polygon to be perpendicular to 
// the specified vector.
function rotations(v) = [ 
	VANG([0,1,0], [0,v[1],v[2]]), 
	VANG([0,0,-1], [v[0],0,v[2]]), 
	VANG([1,0,0], [v[0], v[1],0])];

// Get the appropriate rotations to place a cylinder in world space 
// This is helpful when trying to place a 'line segment' in space
// Book: Essential Mathematics for Games and Interactive Applications (p.75)
function LineRotations(v) = [
	atan2(sqrt(v[0]*v[0]+v[1]*v[1]), v[2]), 
	0, 
	atan2(v[1], v[0])+90];

// The following are already provided in OpenScad, but are
// here for completeness
function VMULTS(v, s) = [v[0]*s, v[1]*s, v[2]*s];
function VDIVS(v,s) = [v[0]/s, v[1]/s, v[2]/s];
function VADDS(v,s) = [v[0]+s, v[1]+s, v[2]+s];
function VSUBS(v,s) = [v[0]-s, v[1]-s, v[2]-s];


// Some more convenience routines.  Not found in OpenScad, but primarily using OpenScad routines
function VMIN(v1,v2) = [min(v1[0],v2[0]), min(v1[1],v2[1]), min(v1[2], v2[2])];
function VMIN3(v1, v2, v3) = VMIN(VMIN(v1,v2),v3);
function VMIN4(v1, v2, v3, v4) = VMIN(VMIN3(v1, v2, v3), v4);

function VMAX(v1,v2) = [max(v1[0],v2[0]), max(v1[1],v2[1]), max(v1[2], v2[2])];
function VMAX3(v1, v2, v3) = VMAX(VMAX(v1,v2),v3);
function VMAX4(v1, v2, v3, v4) = VMAX(VMAX(v1, v2, v3), v4);

// swaps x and y - for doing normals
function VSWAP(v) = [-v[1], v[0], v[2]];


//=======================================
//
// 			MATRIX Routines
//
//=======================================

function MADD2X2(m1, m2) = [
	[m1[0][0]+m2[0][0],  m1[0][1]+m2[0][1]],
	[m1[1][2]+m2[1][0],  m1[1][1]+m2[1][1]]];

// Returns the determinant of a 2X2 matrix
// Matrix specified in row major order
function DETVAL2X2(m) = m[0[0]]*m[1[1]] - m[0[1]]*m[1[0]];

// Returns the determinant of a 3X3 matrix
function DETVAL(m) = 
	m[0[0]]*DETVAL2X2([ [m[1[1]],m[1[2]]], [m[2[1]],m[2[2]]] ]) - 
	m[0[1]]*DETVAL2X2([ [m[1[0]],m[1[2]]], [m[2[0]],m[2[2]]] ]) + 
	m[0[2]]*DETVAL2X2([ [m[1[0]],m[1[1]]], [m[2[0]],m[2[1]]] ]);

//=======================================
//
// 			Helper Routines
//
//=======================================

function AvgThree(v1,v2,v3) = (v1+v2+v3)/3; 
function AvgFour(v1,v2,v3,v4) = (v1+v2+v3+v4)/4;

function CenterOfGravity3(p0, p1, p2) = [
	AvgThree(p0[0], p1[0], p2[0]), 
	AvgThree(p0[1], p1[1], p2[1]), 
	AvgThree(p0[2], p1[2], p2[2])];
function CenterOfGravity4(p0, p1, p2, p3) = [
	AvgThree(p0[0], p1[0], p2[0], p3[0]), 
	AvgThree(p0[1], p1[1], p2[1], p3[1]), 
	AvgThree(p0[2], p1[2], p2[2], p3[2])];

function lerp1(u, p0, p1) = (1-u)*p0 + u*p1;
function lerp(u, v1, v2) = [
	lerp1(u, v1[0], v2[0]),
	lerp1(u, v1[1], v2[2]),
	lerp1(u, v1[2], v2[2])
	];


//=======================================
//
//		Bezier Curve Routines
//
//=======================================

 /* 
	Bernstein Basis Functions
	These are the coefficients for bezier curves

*/

// For quadratic curve (parabola)
function Basis02(u) = pow((1-u), 2);
function Basis12(u) = 2*u*(1-u);
function Basis22(u) = u*u;

// For cubic curves, these functions give the weights per control point.
function Basis03(u) = pow((1-u), 3);
function Basis13(u) = 3*u*(pow((1-u),2));
function Basis23(u) = 3*(pow(u,2))*(1-u);
function Basis33(u) = pow(u,3);

// Derivative basis functions
function BasisDer03(u) = -3*pow((1-u), 2);
function BasisDer13(u) = 3*pow(1-u,2) - 6*(1-u)*u;
function BasisDer23(u) = 6* (1-u)*u - 3*pow(u,2);
function BasisDer33(u) = 3 * pow(u,2);


// Given an array of control points
// Return a point on the quadratic Bezier curve as specified by the 
// parameter: 0<= 'u' <=1
function Bern02(cps, u) = [Basis02(u)*cps[0][0], Basis02(u)*cps[0][1], Basis02(u)*cps[0][2]];
function Bern12(cps, u) = [Basis12(u)*cps[1][0], Basis12(u)*cps[1][1], Basis12(u)*cps[1][2]];
function Bern22(cps, u) = [Basis22(u)*cps[2][0], Basis22(u)*cps[2][1], Basis22(u)*cps[2][2]];

function berp2(cps, u) = Bern02(cps,u)+Bern12(cps,u)+Bern22(cps,u);

//===========
// Cubic Beziers - described by 4 control points
//===========
// Calculate a singe point along a cubic bezier curve
// Given a set of 4 control points, and a parameter 0 <= 'u' <= 1
// These functions will return the exact point on the curve
function PtOnBez2D(p0, p1, p2, p3, u) = [
	Basis03(u)*p0[0]+Basis13(u)*p1[0]+Basis23(u)*p2[0]+Basis33(u)*p3[0],
	Basis03(u)*p0[1]+Basis13(u)*p1[1]+Basis23(u)*p2[1]+Basis33(u)*p3[1]];

// Given an array of control points
// Return a point on the cubic Bezier curve as specified by the 
// parameter: 0<= 'u' <=1
function Bern03(cps, u) = [Basis03(u)*cps[0][0], Basis03(u)*cps[0][1], Basis03(u)*cps[0][2]];
function Bern13(cps, u) = [Basis13(u)*cps[1][0], Basis13(u)*cps[1][1], Basis13(u)*cps[1][2]];
function Bern23(cps, u) = [Basis23(u)*cps[2][0], Basis23(u)*cps[2][1], Basis23(u)*cps[2][2]];
function Bern33(cps, u) = [Basis33(u)*cps[3][0], Basis33(u)*cps[3][1], Basis33(u)*cps[3][2]];

function berp(cps, u) = Bern03(cps,u)+Bern13(cps,u)+Bern23(cps,u)+Bern33(cps,u);

// Calculate a point on a Bezier mesh
// Given the mesh, and the parametric 'u', and 'v' values
function berpm(mesh, uv) = berp(
	[berp(mesh[0], uv[0]), berp(mesh[1], uv[0]),
	berp(mesh[2], uv[0]), berp(mesh[3], uv[0])], 
	uv[1]);

// For a 2D cubic bezier (in x and y), calculate the tangent vector

function BernDer03(cps, u) = [BasisDer03(u)*cps[0][0], BasisDer03(u)*cps[0][1], BasisDer03(u)*cps[0][2]];
function BernDer13(cps, u) = [BasisDer13(u)*cps[1][0], BasisDer13(u)*cps[1][1], BasisDer13(u)*cps[1][2]];
function BernDer23(cps, u) = [BasisDer23(u)*cps[2][0], BasisDer23(u)*cps[2][1], BasisDer23(u)*cps[2][2]];
function BernDer33(cps, u) = [BasisDer33(u)*cps[3][0], BasisDer33(u)*cps[3][1], BasisDer33(u)*cps[3][2]];

function berpTangent(cps, u) = BernDer03(cps,u)+BernDer13(cps,u)+BernDer23(cps,u)+BernDer33(cps,u);



//========================================
// Bezier Mesh normals
//========================================

// The following uses a partial derivative at each point.
// It is very expensive.
// For each point, calculate a partial derivative in both 'u' and 'v' directions, then do a cross
// product between those two to get the normal vector

// Partial derivative in the 'u' direction
function Bern03du(mesh, uv) = (Basis02(uv[0]) *  Basis03(uv[1])  *  (mesh[0][1]-mesh[0][0])) + 
					(Basis12(uv[0]) *  Basis03(uv[1])  *  (mesh[0][2]-mesh[0][1]))+
					(Basis22(uv[0]) *  Basis03(uv[1])  *  (mesh[0][3]-mesh[0][2]));


function Bern13du(mesh, uv) = ( Basis02(uv[0]) *  Basis13(uv[1])  *  (mesh[1][1]-mesh[1][0])) +
					 ( Basis12(uv[0]) *  Basis13(uv[1])  *  (mesh[1][2]-mesh[1][1])) +
					 ( Basis22(uv[0]) *  Basis13(uv[1])  *  (mesh[1][3]-mesh[1][2]));

function Bern23du(mesh, uv) = (Basis02(uv[0]) *  Basis23(uv[1])  *  (mesh[2][1]-mesh[2][0])) +
					(Basis12(uv[0]) *  Basis23(uv[1])  *  (mesh[2][2]-mesh[2][1])) +
					(Basis22(uv[0]) *  Basis23(uv[1])  *  (mesh[2][3]-mesh[2][2]));

function Bern33du(mesh, uv) =  (Basis02(uv[0]) *  Basis33(uv[1])  *  (mesh[3][1]-mesh[3][0])) +
					(Basis12(uv[0]) *  Basis33(uv[1])  *  (mesh[3][2]-mesh[3][1])) +
					(Basis22(uv[0]) *  Basis33(uv[1])  *  (mesh[3][3]-mesh[3][2]));


// Partial derivative in the 'v' direction
function Bern03dv(mesh, uv) = (Basis02(uv[1]) *  Basis03(uv[0])  *  (mesh[1][0]-mesh[0][0])) + 
					(Basis12(uv[1]) *  Basis03(uv[0])  *  (mesh[2][0]-mesh[1][0]))+
					(Basis22(uv[1]) *  Basis03(uv[0])  *  (mesh[3][0]-mesh[2][0]));


function Bern13dv(mesh, uv) = ( Basis02(uv[1]) *  Basis13(uv[0])  *  (mesh[1][1]-mesh[0][1])) +
					 ( Basis12(uv[1]) *  Basis13(uv[0])  *  (mesh[2][1]-mesh[1][1])) +
					 ( Basis22(uv[1]) *  Basis13(uv[0])  *  (mesh[3][1]-mesh[2][1]));

function Bern23dv(mesh, uv) = (Basis02(uv[1]) *  Basis23(uv[0])  *  (mesh[1][2]-mesh[0][2])) +
					(Basis12(uv[1]) *  Basis23(uv[0])  *  (mesh[2][2]-mesh[1][2])) +
					(Basis22(uv[1]) *  Basis23(uv[0])  *  (mesh[3][2]-mesh[2][2]));

function Bern33dv(mesh, uv) =  (Basis02(uv[1]) *  Basis33(uv[0])  *  (mesh[1][3]-mesh[0][3])) +
					(Basis12(uv[1]) *  Basis33(uv[0])  *  (mesh[2][3]-mesh[1][3])) +
					(Basis22(uv[1]) *  Basis33(uv[0])  *  (mesh[3][3]-mesh[2][3]));



function Bern3du(mesh, uv) = Bern03du(mesh, uv) + Bern13du(mesh, uv) + Bern23du(mesh, uv) + Bern33du(mesh, uv);
function Bern3dv(mesh, uv) = Bern03dv(mesh, uv) + Bern13dv(mesh, uv) + Bern23dv(mesh, uv) + Bern33dv(mesh, uv);


// Calculate the normal at a specific u/v on a Bezier patch
function nberpm(mesh, uv) = VUNIT(VPROD([Bern3du(mesh, uv), Bern3dv(mesh, uv)]));





// Given a mesh of control points, and an array that contains the 
// row and column of the quad we want, return the quad as an 
// ordered set of points. The winding will be counter clockwise
function GetControlQuad(mesh, rc) = [ 
	mesh[rc[0]+1][rc[1]], 
	mesh[rc[0]][rc[1]], 
	mesh[rc[0]][rc[1]+1], 
	mesh[rc[0]+1][rc[1]+1]
	];


// Given a mesh, and the 4 parametric points, return a quad that has the appropriate 
// points along the curve, in counter clockwise order
function GetCurveQuad(mesh, u1v1, u2v2) = [
	berpm(mesh, [u1v1[0],u2v2[1]]), 
	berpm(mesh, u1v1),
	berpm(mesh, [u2v2[0],u1v1[1]]), 
	berpm(mesh, u2v2)];

function GetCurveQuadNormals(mesh, u1v1, u2v2) = [[ 
	berpm(mesh, [u1v1[0],u2v2[1]]), 
	berpm(mesh, u1v1),
	berpm(mesh, [u2v2[0],u1v1[1]]), 
	berpm(mesh, u2v2),
	],[
	nberpm(mesh, [u1v1[0],u2v2[1]]), 
	nberpm(mesh, u1v1),
	nberpm(mesh, [u2v2[0],u1v1[1]]), 
	nberpm(mesh, u2v2),
	]];