//---------------------------------------------------------------
//-- Openscad Attachment library
//-- Attach parts easily. Make your designs more reusable and clean
//---------------------------------------------------------------
//-- This is a component of the obiscad opescad tools by Obijuan
//-- (C) Juan Gonzalez-Gomez (Obijuan)
//-- Sep-2012
//-- Extended by Damian Axford
//---------------------------------------------------------------
//-- Released under the GPL license
//---------------------------------------------------------------

use <vector.scad>

$Explode = false;  // override in global config or specific machine file
$AnimateExplode = false;  // set to true to animate the explosion
$AnimateExplodeT = 0;  // animation time, range 0:1

// default connector
DefCon = [[0,0,0],[0,0,1],0,0,0];
DefaultConnector = DefCon;
Con_Default = DefCon;
DefConUp = DefCon;

DefConDown = [[0,0,0],[0,0,-1],0,0,0];

DefConLeft =  [[0,0,0],[-1,0,0],0,0,0];
DefConRight = [[0,0,0],[1,0,0],0,0,0];
DefConFront = [[0,0,0],[0,1,0],0,0,0];
DefConBack =  [[0,0,0],[0,-1,0],0,0,0];


// Connector getter functions

function connector_translation(c) 	= c[0];
function connector_axis(c) 		  	= c[1];
function connector_ang(c) 			= c[2];
function connector_thickness(c) 	= c[3];	   // the thickness of the mounting point
function connector_bore(c) 			= c[4];    // the required diameter of a fixing



//--------------------------------------------------------------------
//-- Draw a connector
//-- A connector is defined a 3-tuple that consist of a point
//--- (the attachment point), and axis (the attachment axis) and
//--- an angle the connected part should be rotate around the
//--  attachment axis
//--
//--- Input parameters:
//--
//--  Connector c = [p , v, ang] where:
//--
//--     p : The attachment point
//--     v : The attachment axis
//--   ang : the angle
//--------------------------------------------------------------------
module connector(c,clr="Gray")
{
  //-- Get the three components from the connector
  p = c[0];
  v = c[1];
  ang = c[2];

  //-- Draw the attachment poing
  color("Gray") point(p);

  //-- Draw the attachment axis vector (with a mark)

  translate(p)
    rotate(a=ang, v=v)
    color(clr) vector(unitv(v)*6, l_arrow=2, mark=true);
}

function invertVector(v) = v * -1;

function invertConnector(a) = [a[0], invertVector(a[1]), a[2], a[3], a[4]];
function offsetConnector(a, o) = [[a[0][0]+o[0], a[0][1]+o[1], a[0][2]+o[2]], a[1], a[2], a[3], a[4]];
function rollConnector(a, ang) = [[a[0][0], a[0][1], a[0][2]], a[1], a[2]+ang, a[3], a[4]];

//-------------------------------------------------------------------------
//--  ATTACH OPERATOR
//--  This operator applies the necesary transformations to the
//--  child (attachable part) so that it is attached to the main part
//--
//--  Parameters
//--    a -> Connector of the main part
//--    b -> Connector of the attachable part
//-------------------------------------------------------------------------
module attach(a,b, Invert=false, ExplodeSpacing = 10, offset=0)
{
  //-- Get the data from the connectors
  pos1 = a[0];  //-- Attachment point. Main part
  v    = Invert ? invertVector(a[1]) : a[1];  //-- Attachment axis. Main part
  roll = a[2];  //-- Rolling angle

  pos2 = b[0];  //-- Attachment point. Attachable part
  vref = b[1];  //-- Atachment axis. Attachable part
                //-- The rolling angle of the attachable part is not used

  //-------- Calculations for the "orientate operator"------
  //-- Calculate the rotation axis
  //raxis = cross(vref,v);
  raxis = orthogonalTo(vref,v);

  //-- Calculate the angle between the vectors
  ang = anglev(vref,v);
  //---------------------------------------------------------

  //-- Apply the transformations to the child ---------------------------

  au = $AnimateExplode ? (1-$AnimateExplodeT) : 1;

  for (i=[0:$children-1])
    //-- Place the attachable part on the main part attachment point
    translate(pos1)
        //-- Orientate operator. Apply the orientation so that
        //-- both attachment axis are paralell. Also apply the roll angle
        rotate(a=roll, v=v)
        rotate(a=ang, v=raxis)
        {
             //-- Attachable part to the origin
            translate(-pos2)
                translate($Explode ? -vref * ExplodeSpacing * au : [0,0,0]) {
                    //assign($Explode=false)
                    $Explode=false; // turn off explosions for children
                    children(i);
                }

            // Show assembly vector
            if ($Explode) {
		        // show attachment axis
		        color([1,0,0, au * 0.7])
		            translate(-vref * ExplodeSpacing * au + vref*offset)
		            vector(vref * ExplodeSpacing, l=abs(ExplodeSpacing * au), l_arrow=2, mark=false);
		    }

        }
}


module attachWithOffset(a,b,o, Invert=false, ExplodeSpacing = 10) {
	for (i=[0:$children-1])
		attach(offsetConnector(a,o), b, Invert=Invert, ExplodeSpacing=ExplodeSpacing) children(i);
}



// --------------------------------------
// Matrix equivalent of the attach module
// --------------------------------------

function attachV(a,b, Invert=false) =
    Invert ? invertVector(a[1]) : a[1];

function attachRAxis(a,b,Invert=false) = orthogonalTo(attachV(a,b,Invert), b[1]);

function attachMatrix(a,b, Invert=false, ExplodeSpacing=10) =
    translate(a[0]) *
    rotate(
        a=a[2],
        v=attachV(a,b,Invert),
        normV=false
    ) *
    rotate(
        a=anglev(b[1], attachV(a,b,Invert)),
        v=attachRAxis(a,b,Invert),
        normV=false
    ) *
    translate(-b[0]) *
    translate($Explode ? (-b[1] * ExplodeSpacing * ($AnimateExplode ? (1-$AnimateExplodeT) : 1)) : [0,0,0])
    ;

// --------------------------------------
// Functions to calc chained connectors
// --------------------------------------

function V3to4(v) = [v[0], v[1], v[2], 1];
function V4to3(v) = [v[0], v[1], v[2]];


function MatrixRotOnly(m) = [
    [m[0][0], m[0][1], m[0][2], 0],
    [m[1][0], m[1][1], m[1][2], 0],
    [m[2][0], m[2][1], m[2][2], 0],
    [0, 0, 0, 1]
];

// c1 = parent connector used in attach
// c2 = child connector used in attach
// c3 = target connector (in child coord frame)
function attachedConnector(c1, c2, c3, ExplodeSpacing=10) =
    [
        attachedTranslation(c1,c2,c3, ExplodeSpacing=ExplodeSpacing),
        attachedDirection(c1,c2,c3, ExplodeSpacing=ExplodeSpacing),
        0,
        c3[3],
        c3[4]
    ]
;

// c1 = parent connector used in attach
// c2 = child connector used in attach
// c3 = target connector (in child coord frame)
function attachedTranslation(c1, c2, c3, v=[0,0,0], ExplodeSpacing=10) =
    V4to3(attachMatrix(c1,c2, ExplodeSpacing=ExplodeSpacing) * V3to4(c3[0]))
;

// c1 = parent connector used in attach
// c2 = child connector used in attach
// c3 = target connector (in child coord frame)
function attachedDirection(c1, c2, c3, v=[0,0,-1], ExplodeSpacing=10) =
    V4to3(MatrixRotOnly(attachMatrix(c1,c2, $Explode=false)) * V3to4(c3[1]))
;


// --------------------------------------
// Utilities
// --------------------------------------

module thread(offset, ExplodeSpacing=10) {
    if($children)
        for(i=[0:$children-1])
            attach(offsetConnector(DefConDown, [0,0,offset]), DefConDown, ExplodeSpacing=ExplodeSpacing * (i+1))
            children(i);
}


// threads along neg z axis, starting at z=0 with first part
// up to 12 children
module threadTogether(a) {
	//echo($children);
	children(0);
	if ($children>1)
		translate([0,0,-a[0]])
		children(1);
	if ($children>2)
		translate([0,0,-a[0]-a[1]])
		children(2);
	if ($children>3)
		translate([0,0,-a[0]-a[1]-a[2]])
		children(3);
	if ($children>4)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]])
		children(4);
	if ($children>5)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]])
		children(5);
	if ($children>6)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]])
		children(6);
	if ($children>7)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]-a[6]])
		children(7);
	if ($children>8)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]-a[6]-a[7]])
		children(8);
	if ($children>9)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]-a[6]-a[7]-a[8]])
		children(9);
	if ($children>10)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]-a[6]-a[7]-a[8]-a[9]])
		children(10);
	if ($children>11)
		translate([0,0,-a[0]-a[1]-a[2]-a[3]-a[4]-a[5]-a[6]-a[7]-a[8]-a[9]-a[10]])
		children(11);
}
