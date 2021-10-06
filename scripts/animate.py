#!/usr/bin/env python

# Renders an animation for a specific machine/assembly combo

import config
import os
import openscad
import shutil
import sys
import c14n_stl
import re
import json
import jsontools
import copy
from types import *
from math import floor
import subprocess
from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw
import textwrap

import views


def machine_dir(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I)


def mapRange(value, leftMin, leftMax, rightMin, rightMax):
    # Figure out how 'wide' each range is
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin

    # Convert the left range into a 0-1 range (float)
    valueScaled = float(value - leftMin) / float(leftSpan)

    # Convert the 0-1 range into a value in the right range.
    return rightMin + (valueScaled * rightSpan)

def easeInOut(t):
    # cubic ease in/out of t in range 0..1
    return t*t * (3.0 - 2.0 * t);

def animateAssembly(mname, aname, prefix, framesPerStep):
    print("Animate Assembly")
    print("----------------")

    print("NB: Make sure you've run parse.py first!")
    print("")

    # load hardware.json
    jf = open(config.paths['json'],"r")
    jso = json.load(jf)
    jf.close()

    # locate required machine
    for m in jso:
        if type(m) is dict and m['type'] == 'machine' and m['title'] == mname:
            print(("Found machine: "+m['title']))

            al = m['assemblies']

            # make target directory
            view_dir = os.path.join(config.paths['assemblies'],machine_dir(m['title']))
            if not os.path.isdir(view_dir):
                os.makedirs(view_dir)

            # locate required assembly
            for a in al:
                if a['title'] == aname:
                    print(("Found assembly: "+a['title']))
                    fn = config.paths['root'] + a['file']
                    if (os.path.isfile(fn)):

                        print("  Checking csg hash")
                        h = openscad.get_csg_hash(config.paths['tempscad'], a['call']);
                        os.remove(config.paths['tempscad']);

                        hashchanged = ('hash' in a and h != a['hash']) or (not 'hash' in a)

                        numSteps = 0
                        frameNum = 0
                        lfn = ""  # last frame filename

                        # Calc number of steps, and grab first view
                        view = {
                            'size': [400,300],
                            'dist': 140,
                            'rotate': [0,0,0],
                            'translate': [0,0,0],
                            'title': 'view'
                        }
                        firstView = True
                        for step in a['steps']:
                            print(("Step: "+str(step['num'])))

                            # generate a transition move?
                            if len(step['views']) > 0:
                                # see if new view is diff from current
                                nv = step['views'][0]

                                if firstView:
                                    view['size'] = nv['size']

                                if ((nv['size'] != view['size']) or (nv['dist'] != view['dist']) or (nv['rotate'] != view['rotate']) or (nv['translate'] != view['translate'])) and (not firstView):
                                    print("Generating transition move...")

                                    # prep tween view
                                    tv = copy.deepcopy(view)

                                    # iterate over frames
                                    for frame in range(0, framesPerStep):
                                        t = easeInOut(frame / (framesPerStep-1.0));
                                        # show previous step during transition
                                        ShowStep = step['num']-1

                                        # tween between view and nv
                                        tv['dist'] = mapRange(t,0,1.0, view['dist'], nv['dist']);
                                        tv['translate'][0] = mapRange(t,0,1.0, view['translate'][0], nv['translate'][0]);
                                        tv['translate'][1] = mapRange(t,0,1.0, view['translate'][1], nv['translate'][1]);
                                        tv['translate'][2] = mapRange(t,0,1.0, view['translate'][2], nv['translate'][2]);
                                        tv['rotate'][0] = mapRange(t,0,1.0, view['rotate'][0], nv['rotate'][0]);
                                        tv['rotate'][1] = mapRange(t,0,1.0, view['rotate'][1], nv['rotate'][1]);
                                        tv['rotate'][2] = mapRange(t,0,1.0, view['rotate'][2], nv['rotate'][2]);

                                        #print("t: "+str(t) +", s: "+str(ShowStep)+", a:"+str(AnimateExplodeT))

                                        # Generate step file
                                        f = open(config.paths['tempscad'], "w")
                                        f.write("include <../config/config.scad>\n")
                                        f.write("DebugConnectors = false;\n");
                                        f.write("DebugCoordinateFrames = false;\n");
                                        f.write("$Explode = false;\n");
                                        f.write("UseSTL=true;\n");
                                        f.write("$AnimateExplode = false;\n");
                                        f.write("$ShowStep = "+ str(ShowStep) +";\n");
                                        f.write(a['call'] + ";\n");
                                        f.close()

                                        # Views
                                        views.PolishTransparentBackground = False
                                        views.PolishCrop = False
                                        lfn = view_dir + "/" +prefix + format(frameNum, '03') + "_" +view['title']+".png"
                                        views.render_view_using_file(prefix + format(frameNum, '03'), config.paths['tempscad'], view_dir, tv, hashchanged, h)
                                        frameNum = frameNum + 1

                                view['dist'] = nv['dist']
                                view['translate'] = nv['translate']
                                view['rotate'] = nv['rotate']
                                firstView = False

                            # iterate over frames to animate the assembly step
                            for frame in range(0, framesPerStep):

                                t = easeInOut(frame / (framesPerStep-1.0));
                                ShowStep = step['num']
                                AnimateExplodeT = t;

                                #print("t: "+str(t) +", s: "+str(ShowStep)+", a:"+str(AnimateExplodeT))

                                # Generate step file
                                f = open(config.paths['tempscad'], "w")
                                f.write("include <../config/config.scad>\n")
                                f.write("DebugConnectors = false;\n");
                                f.write("DebugCoordinateFrames = false;\n");
                                f.write("$Explode = true;\n");
                                f.write("UseSTL=true;\n");
                                f.write("$AnimateExplode = true;\n");
                                f.write("$ShowStep = "+ str(ShowStep) +";\n");
                                f.write("$AnimateExplodeT = "+ str(AnimateExplodeT) +";\n");
                                f.write(a['call'] + ";\n");
                                f.close()

                                # Views
                                views.PolishTransparentBackground = False
                                views.PolishCrop = False
                                fn = view_dir + "/" +prefix + format(frameNum, '03') + "_" +view['title']+".png"
                                print(("Rendering: "+fn))
                                views.render_view_using_file(prefix + format(frameNum, '03'), config.paths['tempscad'], view_dir, view, hashchanged, h)
                                frameNum = frameNum + 1

                                if frame == 0:
                                    # load previous image for cross-fade
                                    if lfn != "":
                                        imgPrev = Image.open(lfn)

                                    # Annotate and extend first frame with step info
                                    img = Image.open(fn)
                                    imgNew = img.copy()

                                    # go back one to overwrite first frame
                                    frameNum = frameNum - 1

                                    # extend a bit
                                    for extra in range(0, 2*framesPerStep):
                                        if lfn != "":
                                            alpha = extra / (1.0*framesPerStep)
                                            if (alpha > 1.0):
                                                alpha = 1.0
                                            print(("Blending: "+str(alpha) +", "+str(frameNum)))
                                            imgNew = Image.blend(imgPrev,img,alpha)

                                        draw = ImageDraw.Draw(imgNew, "RGBA")
                                        font = ImageFont.truetype("Tahoma.ttf", 12)
                                        draw.rectangle((0, 0, view['size'][0], 30), fill = (240,240,240))
                                        margin = 30
                                        offset = 10
                                        for line in textwrap.wrap(step['desc'], width=((view['size'][0]-2*margin) / (draw.textsize("abcdefghij")[0]/10))):
                                            draw.rectangle((0, offset, view['size'][0], offset + 20), fill = (240,240,240))
                                            draw.rectangle((0, offset+20, view['size'][0], offset + 22), fill = (200,200,200))
                                            draw.text((margin, offset), line, (0,0,0), font=font)
                                            offset += font.getsize(line)[1]

                                        # draw step number
                                        draw.ellipse((5, 5, 25, 25), fill = (255,140,50), outline =(255,140,50))
                                        draw.text((11,8),str(step['num']),(255,255,255),font=font)

                                        fn = view_dir + "/" +prefix + format(frameNum, '03') + "_" +view['title']+".png"
                                        frameNum = frameNum + 1
                                        print(("Saving: "+fn))
                                        imgNew.save(fn)

                                lfn = fn


                        # final turntable, using last view as starting point
                        print("Generating final turntable")
                        tv = copy.deepcopy(view)
                        for frame in range(0, framesPerStep*2):
                            t = easeInOut(frame / ((framesPerStep*2.0)-1.0));
                            ShowStep = 100

                            # tween between view and nv
                            r = mapRange(t,0,1.0, 0, 360)
                            tv['rotate'][2] = view['rotate'][2] + r
                            if tv['rotate'][2] > 360:
                                tv['rotate'][2] = tv['rotate'][2] - 360

                            #print("t: "+str(t) +", r:"+str(r))

                            # Generate step file
                            f = open(config.paths['tempscad'], "w")
                            f.write("include <../config/config.scad>\n")
                            f.write("DebugConnectors = false;\n");
                            f.write("DebugCoordinateFrames = false;\n");
                            f.write("UseSTL=true;\n");
                            f.write("$Explode = false;\n");
                            f.write("$ShowStep = "+ str(ShowStep) +";\n");
                            f.write(a['call'] + ";\n");
                            f.close()

                            # Views
                            views.PolishTransparentBackground = False
                            views.PolishCrop = False
                            views.render_view_using_file(prefix + format(frameNum, '03'), config.paths['tempscad'], view_dir, tv, hashchanged, h)
                            frameNum = frameNum + 1


                        numFrames = frameNum

                        # build video
                        cmd = "ffmpeg -r "+str(framesPerStep)+" -y -i "+view_dir + "/" + prefix+"%03d_"+view['title']+".png -vcodec libx264 -pix_fmt yuv420p "+view_dir + "/" + prefix+".mp4"
                        print(("Encoding video with: "+cmd))
                        os.system(cmd)

                        # build animated gif
                        cmd = "convert "+view_dir + "/" + prefix+".mp4 "+view_dir + "/" + prefix+".gif"
                        print(("Creating GIF with: "+cmd))
                        os.system(cmd)

                        # clean up temporary images
                        #for frame in range(0, numFrames):
                        #    os.remove(view_dir + "/" +prefix + format(frame, '03') + "_" +view['title']+".png");

                        print("Done")

                        try:
                            if sys.platform == "darwin":
                                subprocess.check_output(['osascript','-e','display notification "Animation Complete" with title "Animation"'])
                        except:
                            print("Exception running osascript")

                    else:
                        print(("    Error: scad file not found: "+a['file']))

    return 0


if __name__ == '__main__':
    if len(sys.argv) == 5:
        animateAssembly(sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]) )
    else:
        print("Usage: ./animate.py <machine> <assembly> <output prefix> <framesPerStep>")
        print("Example: ./animate.py House Window windowAnim 20");
