#!/usr/bin/env python

# Renders pre-defined views into the images directory

import config
import os
from PIL import Image, PngImagePlugin
import sys
import shutil
import openscad
import re
import hashlib

# OpenSCAD default background colour
bkc = (255,255,229,255)

PolishTransparentBackground = True
PolishCrop = True

def view_filename(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I) + '.png'


def read_hashes_from_png(filename):
    res = {"csghash":"", "viewhash":""}

    if os.path.isfile(filename):
        # re-open and read meta data
        try:
            img = Image.open(filename)

            if "csghash" in img.info:
                res['csghash'] = img.info['csghash']
            if "viewhash" in img.info:
                res['viewhash'] = img.info['viewhash']
        except:
            print("Error reading image file")

    return res


def polish(filename, w, h, hash="", viewhash=""):
    print("  Polishing...")

    try:
        img = Image.open(filename)
        img = img.convert("RGBA")

        pixdata = img.load()

        # Read top left pixel color - not robust to zoomed in images
        # tlc = pixdata[0,0]

        # init clipping bounds
        x1 = img.size[0]
        x2 = 0
        y1 = img.size[1]
        y2 = 0

        #Added by JG to fix type error:
        w=int(w)

        h=int(h)

        # Set background to white and transparent

        for y in range(img.size[1]):
            solidx = 0
            solidy = 0
            for x in range(img.size[0]):
                if pixdata[x, y] == bkc:
                    pixdata[x, y] = (255, 255, 255, 0 if PolishTransparentBackground else 255)
                else:
                    if solidx == 0 and x < x1:
                        x1 = x
                    if solidy == 0 and y < y1:
                        y1 = y
                    solidx = x
                    solidy = y
            if solidx > x2:
                x2 = solidx
            if solidy > y2:
                y2 = solidy

        x2 += 2
        y2 += 2


        # downsample (half the res)
        img = img.resize((w, h), Image.ANTIALIAS)

        # crop
        if (x1 < x2 and y1 < y2 and PolishCrop):
            img = img.crop((x1/2,y1/2,x2/2,y2/2))


        # add hash to meta data
        meta = PngImagePlugin.PngInfo()

        # copy metadata into new object
        #for k,v in im.info.iteritems():
        #    if k in reserved: continue
        meta.add_text("csghash", hash, 0)
        meta.add_text("viewhash", viewhash, 0)

        # Save it
        img.save(filename, "PNG", pnginfo=meta)

        img.close()
    except Exception as e:
        print(("  Exception error", sys.exc_info()[0]))
        #print(type(e))
        #print(e.args)
        #print(e)


def render_view_using_file(obj_title, scadfile, dir, view, hashchanged, hash=""):
    png_name = dir + '/' + view_filename(obj_title + '_'+view['title'])

    view['filepath'] = png_name

    oldhashes = read_hashes_from_png(png_name)

    viewstr = (str(view['size']) + str(view['translate']) + str(view['rotate']) + str(view['dist'])).encode('utf-8')
    viewhash = hashlib.md5(viewstr).hexdigest();

    if (not os.path.isfile(png_name) or (hash != oldhashes['csghash']) or (viewhash != oldhashes['viewhash'])):
        print(("        Updating: "+png_name))

        # Up-sample images
        w = view['size'][0] * 2
        h = view['size'][1] * 2

        dx = float(view['translate'][0])
        dy = float(view['translate'][1])
        dz = float(view['translate'][2])

        rx = float(view['rotate'][0])
        ry = float(view['rotate'][1])
        rz = float(view['rotate'][2])

        d = float(view['dist'])
        camera = "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f" % (dx, dy, dz, rx, ry, rz, d)

        openscad.run(
                    "--imgsize=%d,%d" % (w, h),
                    "--projection=p",
                    "--camera=" + camera,
                    "-o", png_name,
                    scadfile)

        polish(png_name, w/2, h/2, hash, viewhash)

        print()

    else:
        print("        View up to date")


def render_view(obj_title, obj_call, dir, view, hashchanged, hash="", includes=[], debug=False, useVitaminSTL=True):

    # make a file to use the module
    #
    f = open(config.paths['tempscad'], "w")
    f.write("include <../config/config.scad>\n")
    for i in includes:
        f.write("include <"+i+">\n")
    f.write("UseSTL=true;\n");
    if useVitaminSTL:
        f.write("UseVitaminSTL=true;\n")
    else:
        f.write("UseVitaminSTL=false;\n")
    if debug:
        f.write("DebugConnectors=true;\n");
        f.write("DebugCoordinateFrames=true;\n");
    else:
        f.write("DebugConnectors=false;\n");
        f.write("DebugCoordinateFrames=false;\n");
    f.write(obj_call + ";\n");
    f.close()

    render_view_using_file(obj_title, config.paths['tempscad'], dir, view, hashchanged, hash)

    if os.path.isfile(config.paths['tempscad']):
        os.remove(config.paths['tempscad'])
