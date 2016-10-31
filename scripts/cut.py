#!/usr/bin/env python

# Renders views for cut parts
import config
import os
import openscad
import shutil
import sys
import c14n_stl
import re
import json
import jsontools
from types import *

from views import polish;
from views import render_view;
from views import render_view_using_file;


def machine_dir(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I)


def cut():
    print("Cut Parts")
    print("---------")

    # load hardware.json
    jf = open("../../build/hardware.json","r")
    jso = json.load(jf)
    jf.close()

    # for each machine
    for m in jso:
        if type(m) is DictType and m['type'] == 'machine':
            print(m['title'])

            al = m['cut']

            # make target directory
            if not os.path.isdir(config.paths['cutpartsimages']):
                os.makedirs(config.paths['cutpartsimages'])

            for a in al:
                print("  "+a['title'])
                fn = config.paths['root'] + a['file']
                if (os.path.isfile(fn)):

                    print("    Checking csg hash")
                    h = openscad.get_csg_hash(config.paths['tempscad'], a['call']);
                    os.remove(config.paths['tempscad']);

                    hashchanged = ('hash' in a and h != a['hash']) or (not 'hash' in a)

                    # update hash in json
                    a['hash'] = h

                    # Generate completed part file
                    f = open(config.paths['tempscad'], "w")
                    f.write("include <../config/config.scad>\n")
                    f.write("DebugConnectors = false;\n");
                    f.write("DebugCoordinateFrames = false;\n");
                    f.write(a['completeCall'] + ";\n");
                    f.close()

                    # Completed views
                    for view in a['views']:
                        render_view_using_file(a['title'], config.paths['tempscad'], config.paths['cutpartsimages'], view, hashchanged, h)

                    # Fabrication Steps
                    for step in a['steps']:
                        # Generate step file
                        f = open(config.paths['tempscad'], "w")
                        f.write("include <../config/config.scad>\n")
                        f.write("DebugConnectors = false;\n");
                        f.write("DebugCoordinateFrames = false;\n");
                        f.write("$Explode = true;\n");
                        f.write("$ShowStep = "+ str(step['num']) +";\n");
                        f.write(a['call'] + ";\n");
                        f.close()

                        # Views
                        print("      Step "+str(step['num']))
                        for view in step['views']:
                            render_view_using_file(a['title']+'_step'+str(step['num']), config.paths['tempscad'], config.paths['cutpartsimages'], view, hashchanged, h)


                else:
                    print("    Error: scad file not found: "+a['file'])


    # Save changes to json
    with open(config.paths['json'], 'w') as f:
        f.write(json.dumps(jso, sort_keys=False, indent=4, separators=(',', ': ')))

    return 0


if __name__ == '__main__':
    cut()
