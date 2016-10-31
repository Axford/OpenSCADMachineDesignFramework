#!/usr/bin/env python

# Utility script to start a new project, using the current project as a template

import config
import sys
import os
import string
from shutil import copytree, ignore_patterns, copy2
import subprocess

class cd:
    """Context manager for changing the current working directory"""
    def __init__(self, newPath):
        self.newPath = os.path.expanduser(newPath)

    def __enter__(self):
        self.savedPath = os.getcwd()
        os.chdir(self.newPath)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.savedPath)


def startaproject(proj_parent_path, proj_name):

    # TODO: build directory structure, copy key files, use template for root scad file

    proj_path = os.path.join(proj_parent_path, proj_name)

    if (os.path.isdir(proj_parent_path) is not True):
        print("Error: Parent directory does not exist: "+proj_parent_path)
        sys.exit()

    if (os.path.isdir(proj_path)):
        print("Error: Project directory already exists: "+proj_path)
        sys.exit()
    else:
        print("Creating project directory: "+proj_path)
        os.mkdir(proj_path)

    print("Create directory structure")
    try:
        os.mkdir(proj_path + '/hardware')
        os.mkdir(proj_path + '/hardware/assemblies')
        os.mkdir(proj_path + '/hardware/build')
        os.mkdir(proj_path + '/hardware/config')
        os.mkdir(proj_path + '/hardware/docs')
        os.mkdir(proj_path + '/hardware/images')
        os.mkdir(proj_path + '/hardware/printedparts')
        os.mkdir(proj_path + '/hardware/cutparts')
        os.mkdir(proj_path + '/hardware/sandbox')
        os.mkdir(proj_path + '/hardware/utils')
    except OSError:
        pass

    print("Copy template config files")
    tc = os.path.join(config.paths['template'],'config')
    copy2(os.path.join(tc, 'config.scad'), proj_path + "/hardware/config/config.scad")
    copy2(os.path.join(tc, 'utils.scad'), proj_path + "/hardware/config/utils.scad")
    copy2(os.path.join(tc, 'assemblies.scad'), proj_path + "/hardware/config/assemblies.scad")
    copy2(os.path.join(tc, 'printedparts.scad'), proj_path + "/hardware/config/printedparts.scad")
    copy2(os.path.join(tc, 'cutparts.scad'), proj_path + "/hardware/config/cutparts.scad")
    copy2(os.path.join(tc, 'vitamins.scad'), proj_path + "/hardware/config/vitamins.scad")

    print("Setup root scad file")
    templateFile = os.path.join(config.paths['template'],"root.scad")
    outFile = proj_path + "/hardware/" + proj_name + ".scad"
    if os.path.isfile(templateFile):
        f = open(templateFile,"r")
        template = f.read()
        f.close()

        s = string.Template(template).substitute({'name':proj_name});

        with open(outFile,'w') as o:
            o.write(s)
    else:
        print(templateFile + " root template is missing")

    print("Init git")
    with cd(os.path.join(proj_path)):
        subprocess.call(['git', 'init'])
        subprocess.call(['git', 'add', '.'])
        subprocess.call(['git', 'commit', '-m', 'Initial commit'])


    print("Setup framework submodule")
    with cd(os.path.join(proj_path, 'hardware')):
        subprocess.call(['git', 'submodule', 'add', 'https://github.com/Axford/OpenSCADMachineDesignFramework.git', 'framework'])
        subprocess.call(['git', 'submodule', 'update', '--init', '--recursive'])


    print("")
    print("Project setup complete")

if __name__ == '__main__':
    if len(sys.argv) == 3:
        startaproject(sys.argv[1], sys.argv[2])
    else:
        print("Usage: ./startaproject.py <in-dir> <name>")
        print("  <in-dir> is directory within which to create the project")
        print("  <name> is used for the top-level directory and for the root scad file, no spaces!")
