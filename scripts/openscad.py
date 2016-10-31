from __future__ import print_function

import config
import subprocess
import hashlib
import re
import os
from c14n_stl import canonicalise

def stl_filename(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I) + '.stl'


def get_csg_hash(scadname, obj_call, includes=[]):
    f = open(scadname, "w")
    f.write("include <../config/config.scad>\n")
    for i in includes:
        f.write("include <"+i+">\n")
    f.write("UseSTL=false;\n");
    f.write("UseVitaminSTL=false;\n");
    f.write("DebugConnectors=false;\n");
    f.write("DebugCoordinateFrames=false;\n");
    f.write(obj_call + ";\n");
    f.close()

    return get_csg_hash_for(scadname)


def get_csg_hash_for(scadname):
    run_silent("-o", config.paths['dummycsg'], scadname)

    hasher = hashlib.md5()
    with open(config.paths['dummycsg'], 'rb') as afile:
        buf = afile.read()
        hasher.update(buf)

    # remove dummy.csg
    os.remove(config.paths['dummycsg'])

    return hasher.hexdigest()

def render_stl(scadname, stlpath, obj_call, includes=[]):
    f = open(scadname, "w")
    f.write("include <../config/config.scad>\n")
    for i in includes:
        f.write("include <"+i+">\n")
    f.write("UseSTL=false;\n")
    f.write("UseVitaminSTL=false;\n")
    f.write("DebugConnectors=false;\n")
    f.write("DebugCoordinateFrames=false;\n")
    f.write(obj_call + ";\n")
    f.close()

    run("-o", stlpath, scadname)

    return canonicalise(stlpath)


def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

def run_silent(*args):
    log = open(config.paths['openscadlog'], "w")
    programs = ['OpenSCAD', 'openscad']
    for locate_prog in programs:
        prog = which(locate_prog)
        if prog != None:
            break
    if prog == None:
        print("Unable to locate OpenSCAD executable... check your PATH")
    else:
        subprocess.call([prog] + list(args), stdout = log, stderr = log)
    log.close()

def run(*args):
    print("openscad", end=" ")
    for arg in args:
        print(arg, end=" ")
    print()
    run_silent(*args)
