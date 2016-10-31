#!/usr/bin/env python
from __future__ import print_function

import sys
from subprocess import call, check_output
import hashlib
import re
import os


def calc_plastic_required(stlpath):
    try:
        p = re.compile("\((.*)cm3\)", re.MULTILINE)
        o = check_output(['slic3r','-o','tmp.gcode',stlpath])
        res = p.search(o)

        #remove tmp.gcode
        if os.path.isfile('tmp.gcode'):
            os.remove('tmp.gcode')

        # Match stdout of form: Filament required: 9439.3mm (66.7cm3)
        # weight based on density of 1.26 g/cm3

        if res:
            vol = float(res.group(1))
            weight = vol * 1.25/1000
            return {'plasticVolume': vol, 'plasticWeight':weight}
        else:
            return {}
    except:
        return {}

if __name__ == '__main__':
    if len(sys.argv) == 2:
        sys.exit(calc_plastic_required(sys.argv[1]))
    else:
        print("Usage: slic3r.py stlpath")
