#!/usr/bin/env python

# Utility script to create new parts/assemblies

import config
import sys
import os
import string


def adda(t, n, d):

    template = ""
    templateFile = ""
    outFile = ""
    incFile = ""
    configFile = ""
    module = ""
    sandbox = ""

    if t == "assembly":
        print("Creating assembly")

        templateFile = os.path.join(config.paths['template'],"assemblies","assembly.scad")
        outFile = os.path.join(config.paths['assemblies'], n + ".scad")
        incFile = outFile[3:]
        configFile = os.path.join(config.paths['config'],"assemblies.scad")
        module = n + "Assembly"
        sandbox = module

    elif t == "printedpart":
        print("Creating printedpart")

        templateFile = os.path.join(config.paths['template'],"printedparts","printedpart.scad")
        outFile = os.path.join(config.paths['printedparts'], n + ".scad")
        incFile = outFile[3:]
        configFile = os.path.join(config.paths['config'],"printedparts.scad")
        module = n + "_STL"
        sandbox = n

    elif t == "cutpart":
        print("Creating cutpart")

        templateFile = os.path.join(config.paths['template'],"cutparts","cutpart.scad")
        outFile = os.path.join(config.paths['cutparts'], n + ".scad")
        incFile = outFile[3:]
        configFile = os.path.join(config.paths['config'],"cutparts.scad")
        module = n
        sandbox = n


    elif t == "vitamin":
        print("Creating vitamin")

        templateFile = os.path.join(config.paths['template'],"vitamins","vitamin.scad")
        outFile = os.path.join(config.paths['vitamins'],n + ".scad")
        incFile = os.path.join("..","framework", outFile[3:])
        configFile = os.path.join(config.paths['config'],"vitamins.scad")
        module = n
        sandbox = n

    if os.path.isfile(outFile):
        print("File already exists!")
        sys.exit();


    if os.path.isfile(templateFile):
        f = open(templateFile,"r")
        template = f.read()
        f.close()

        s = string.Template(template).substitute({'name':n, 'description':d});

        with open(outFile,'w') as o:
            o.write(s)

        with open(configFile, "a") as o:
            o.write("include <"+incFile+">\n")

    else:
        print(templateFile + " template is missing")

    # Sandbox
    templateFile = os.path.join(config.paths['template'],"sandbox","sandbox.scad")
    outFile = os.path.join(config.paths['sandbox'], t + "_" + sandbox + ".scad")
    if os.path.isfile(templateFile):
        f = open(templateFile,"r")
        template = f.read()
        f.close()

        s = string.Template(template).substitute({'module':module});

        with open(outFile,'w') as o:
            o.write(s)

    else:
        print(templateFile + " template is missing")


if __name__ == '__main__':
    if len(sys.argv) == 4:
        adda(sys.argv[1], sys.argv[2], sys.argv[3] )
    else:
        print("Usage: ./adda.py <type> <name> <description>")
        print("Types: assembly | cutpart | printedpart | vitamin")
