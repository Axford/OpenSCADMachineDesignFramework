#!/usr/bin/env python

# Run the various build scripts

import config
import sys, getopt
import os
from parse import parse_machines
from machines import machines
from assemblies import assemblies
from vitamins import vitamins
from cut import cut
from printed import printed
from guides import guides
from catalogue import catalogue
from subprocess import check_output

def build(argv):

    doCatalogue = True
    doQuick = False
    try:
        opts, args = getopt.getopt(argv,"hcq",[])
    except getopt.GetoptError:
        print 'build.py -h -c -q'
        print ''
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'Usage: -h -c -q'
            print ''
            print '  -c   Skip catalogue'
            print '  -q   Quick build - skip assemblies, guide and catalogue'
            sys.exit()
        if opt in ("-c"):
            doCatalogue = False
        if opt in ("-q"):
            doQuick = True
            doCatalogue = False

    print("Build")
    print("-----")

    print("Backup current json...")
    oldjso = None
    if os.path.isfile(config.paths['json']) and not os.path.isfile(config.paths['jsonbackup']):
        os.rename(config.paths['json'], config.paths['jsonbackup'])

    errorlevel = 0

    errorlevel += parse_machines()

    if errorlevel == 0:
        errorlevel += vitamins()
    if errorlevel == 0:
        errorlevel += cut()
    if errorlevel == 0:
        errorlevel += printed()
    if errorlevel == 0 and not doQuick:
        errorlevel += assemblies()
    if errorlevel == 0:
        errorlevel += machines()

    if errorlevel == 0 and not doQuick:
        errorlevel += guides()

    if doCatalogue and not doQuick:
        catalogue()

    # if everything is ok then delete backup - no longer required
    if errorlevel == 0 and os.path.isfile(config.paths['jsonbackup']):
        os.remove(config.paths['jsonbackup'])

    try:
        if sys.platform == "darwin":
            check_output(['osascript','-e','display notification "Build Complete" with title "Build Process"'])
    except:
        print("Exception running osascript")

    print("")
    print("==============")
    print("Build Complete")

    if errorlevel > 0:
        print("Error: " + str(errorlevel))

    return errorlevel

if __name__ == '__main__':
    build(sys.argv[1:])
