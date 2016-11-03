#!/usr/bin/env python

# Renders views and STL cache for vitamins

import config
import os
import openscad
import shutil
import sys
import c14n_stl
import re
import json
from types import *

from views import polish;
from views import render_view;


def compile_vitamin(v):

    #
    # Make the target directories
    #
    if not os.path.isdir(config.paths['vitaminsstl']):
        os.makedirs(config.paths['vitaminsstl'])

    if not os.path.isdir(config.paths['vitaminsimages2']):
        os.makedirs(config.paths['vitaminsimages2'])

    # Compile
    print("  "+v['title'])
    fn = os.path.join('..', v['file'])
    if (os.path.isfile(fn)):

        print("    Checking csg hash")
        h = openscad.get_csg_hash(config.paths['tempscad'], v['call']);
        os.remove(config.paths['tempscad']);

        hashchanged = ('hash' in v and h != v['hash']) or (not 'hash' in v)

        # update hash in json
        v['hash'] = h

        # STL
        print("    STL Parts")
        if 'parts' in v:
            for part in v['parts']:
                stlpath = os.path.join(config.paths['vitaminsstl'], openscad.stl_filename(part['title']))
                if hashchanged or (not os.path.isfile(stlpath)):
                    print("      Rendering STL...")
                    openscad.render_stl(config.paths['tempscad'], stlpath, part['call'])
                else:
                    print("      STL up to date")

        # Views
        print("    Views")
        for view in v['views']:
            print("      "+view['title'])

            render_view(v['title'], v['call'], config.paths['vitaminsimages2'], view, hashchanged, h)


    else:
        print("    Error: scad file not found: "+v['file'])

def vitamins():
    print("Vitamins")
    print("--------")

    # load hardware.json
    jf = open(config.paths['json'],"r")
    jso = json.load(jf)
    jf.close()

    # for each machine
    for m in jso:
        if type(m) is DictType and m['type'] == 'machine':
            print(m['title'])

            vl = m['vitamins']

            for v in vl:
                compile_vitamin(v)


    # Save changes to json
    with open(config.paths['json'], 'w') as f:
        f.write(json.dumps(jso, sort_keys=False, indent=4, separators=(',', ': ')))

    return 0


if __name__ == '__main__':
    vitamins()
