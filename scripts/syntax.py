#!/usr/bin/env python

# Build the include tree for each file and check files in turn for syntax errors

import config
import os
import shutil
import sys
import re
import json
import jsontools
import openscad
from types import *
import static



def contains_syntax_error(filename):
    openscad.run_silent('-o',config.paths['dummycsg'],filename);
    errorlevel = 0
    for line in open(config.paths['openscadlog'], "rt").readlines():
        # errors
        r = re.search(r".*(Parser.*line\s(\w+): syntax error)$", line, re.I)
        if r:
            errorlevel = int(r.group(2))
            continue

    return errorlevel


def contains_warnings(filename):
    openscad.run_silent('-o',config.paths['dummycsg'],filename);
    warnings = []
    for line in open(config.paths['openscadlog'], "rt").readlines():
        # warnings
        r = re.search(r".*WARNING:(.*)$", line, re.I)
        if r:
            warnings.append(line)

    return warnings

def check_syntax(filename, level=0):
    res = {'filename':filename, 'errorLevel':0, 'errorMessage':'', 'warnings':[], 'includes':[]}

    if os.path.isfile(filename):
        # parse includes
        with open(filename,'r') as f:
            ia = static.extract_includes(f)

        if level == 0:
            res['warnings'] = contains_warnings(filename)

        # execute with openscad and check log for syntax error:
        errorlevel = contains_syntax_error(filename)
        if errorlevel > 0:
            res['errorLevel'] = errorlevel
            res['errorMessage'] = "Syntax error near line "+str(errorlevel)
            print(("Syntax error near line "+str(errorlevel)+" in "+filename))

        # if error, do the same for all included files
        if errorlevel > 0:
            for inc in ia:
                fn = os.path.normpath(os.path.join(os.path.dirname(filename), inc))
                res['includes'].append(check_syntax(fn, level+1))

    else:
        res['errorLevel'] = 1
        res['errorMessage'] = 'File not found'
        print(("File not found: "+filename))

    # Print warnings
    if level == 0:
        for w in res['warnings']:
            print(("Warning: "+w))

    return res

def syntax(filename):
    res = check_syntax(filename)

    return res['errorLevel']


if __name__ == '__main__':
    if len(sys.argv) == 2:
        sys.exit(syntax(sys.argv[1]))
    else:
        print("usage: syntax.py filename")
