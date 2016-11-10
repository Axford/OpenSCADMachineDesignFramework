# OpenSCAD for Machine Design framework

## Overview

Re-usable framework for complex machine design in OpenSCAD (e.g. CNC machines, robotics).  In use, the framework is embedded within a specific project as a git submodule.  The framework can/should be used to start new machine projects and will build the appropriate file structure along with correctly configuring the framework submodule.

Example of an animated assembly created using the framework:

![GyroAnt Animated Assembly](https://github.com/swindonmakers/GyroAnt/raw/master/hardware/assemblies/GyroAnt/GyroAnt.gif)


## Framework Principles

* Supports efficient, robust collaborative design with clear naming conventions, coding styles and file structure
* Encourages reusable parts that can be shared across projects (vitamins in particular)
* Automates slow, repetitive and complex tasks such as:
  * STL generation
  * Generation of assembly guides, sourcing guides and printing guides
  * Pretty pictures for Assembly Guide, website, etc
  * Assembly animations
* All documentation in markdown format and HTML, so...
  * it can be rendered automatically by github
  * it is very readable
  * is printable
* Integrated with github, but easily extended to other SCMs


## Vitamin Catalogue

This framework project includes a growing library of re-usable **vitamins** - please submit new vitamins to the project by pull request.

The latest [Vitamin Catalogue](docs/VitaminCatalogue.md) is located under `/docs/VitaminCatalogue.md`.


## Tutorials

See the [Tutorials](docs/Tutorials.md) for a guided walk-through of the framework and basic design practises.
