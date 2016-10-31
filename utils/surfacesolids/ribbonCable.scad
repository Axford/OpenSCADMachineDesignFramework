include <maths.scad>
include <Renderer.scad>


module ribbonCable(cables=0, cableRadius = 0.5, cableSpacing=0, points, vectors, colors, steps=20, debug=false) {

    cps = points;

    cableR = cableRadius;
    cableD = cableR*2;

    cableColors = colors;

    // vectors to align the strips of the ribbon
    cv = vectors;

    cableWidth = (cables - 1) * (cableSpacing > 0 ? cableSpacing : cableD);
    cableWidth2 = (cables - 1) * cableD;

    cps2 = [
        cps[0] + VNORM(cv[0]) * cableWidth,
        cps[1] + VNORM(cv[1]) * cableWidth2,
        cps[2] + VNORM(cv[2]) * cableWidth2,
        cps[3] + VNORM(cv[3]) * cableWidth
    ];

    if (debug) {

        // draw control points and control vectors
        for (i=[0:3]) {
            color("black")
                PlaceLine(
                    [cps[i], cps2[i]],
                    radius=0.3
                );

            translate(cps[i])
                frame();
        }
    }

    for (cable= [0:cables-1])
        color(cableColors[cable])
        for (i=[0:steps-1]) {
            u1=i/steps;
            u2 = (i+1.02)/steps;
            p1 = berp(cps, u1);
            p2 = berp(cps2, u1);
            p3 = berp(cps, u2);
            p4 = berp(cps2, u2);
            n2 = p2 - p1;
            n3 = p4 - p3;

            PlaceLine([
                p1 + n2 * cable/(cables-1),
                p3 + n3 * cable/(cables-1)
            ], radius=cableR, $fn=6);

        }
}

// Example

*ribbonCable(
    cables=5,
    cableRadius = 0.6,
    points= [
        [0,30,0],
        [0,20,50],
        [90,0,30],
        [100,0,0]
    ],
    vectors = [
        [0, 1 ,0],
        [0.3, 1, 0],
        [0.7, 0.3, 0],
        [1, 0,0]
    ],
    colors = [
        "blue",
        "orange",
        "red",
        "pink",
        "yellow"
    ]
);
