#!/usr/bin/env python

# Generate views for each machine

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
from views import render_view_using_file;


def machines():
    print("Machines")
    print("--------")

    #
    # Make the target directories
    #
    if not os.path.isdir(config.paths['machineimages']):
        os.makedirs(config.paths['machineimages'])

    # load hardware.json
    jf = open(config.paths['json'],"r")
    jso = json.load(jf)
    jf.close()

    # for each machine
    for m in jso:
        if type(m) is DictType and m['type'] == 'machine':
            print(m['title'])

            fn = config.paths['root'] + m['file']

            if (os.path.isfile(fn)):

                print("  Checking csg hash")
                h = openscad.get_csg_hash_for(fn);

                hashchanged = ('hash' in m and h != m['hash']) or (not 'hash' in m)

                # update hash in json
                m['hash'] = h


                # Views
                print("  Views")
                for c in m['children']:
                    if type(c) is DictType and c['type'] == 'view':
                        view = c
                        print("    "+view['title'])

                        render_view_using_file(m['title'], fn, config.paths['machineimages'], view, hashchanged, h)


            else:
                print("    Error: scad file not found: "+v['file'])


    # Save changes to json
    with open(config.paths['json'], 'w') as f:
        f.write(json.dumps(jso, sort_keys=False, indent=4, separators=(',', ': ')))

    return 0


if __name__ == '__main__':
    machines()
