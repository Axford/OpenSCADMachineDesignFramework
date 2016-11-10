# OpenSCAD Machine Design Framework - Tutorials

This guide is laid out as a series of tutorials that progressively introduce more complex modelling scenarios, features and concepts.  There is a consistent theme through-out all the tutorials, to illustrate the typical evolution of a project from first experimental parts through to finished, published design.

The theme for the tutorials is the development of a printed quad-copter frame based around the hardware for a Hubsan X4 (i.e. motors, battery, flight-controller).

The finished tutorial project can be found on github at:
[https://github.com/Axford/QuadFrame](https://github.com/Axford/QuadFrame)


 1. [Basic quad frame layout with motors](Tutorial1.md)
    * Starting a project, python pre-requisites
    * Simple assembly of a printed part and an existing vitamin
    * Using the vitamin catalogue
    * Use of utility tools and assembly guide generation
    * Sandbox
    * Printing the STL
 2. [Refined frame, including battery](Tutorial2.md)
    * Sub-assemblies, more printed parts and more existing vitamins
    * Project config files
    * Incorporating other utility libraries
    * Documentation templates
 3. [Adding the flight controller](Tutorial3.md)
    * Defining a new simple vitamin (non-parameterised, 1 part)
    * Simple cut parts
    * Importing a 3rd party vitamin
    * Porting existing OpenSCAD code to a vitamin
    * Updating the vitamin catalogue
 4. More sophisticated vitamins (parameterised, enum types)
    * Type getter functions
    * Catalogue support
    * Multi-part vitamins (STL)
    * Vitamin dependencies (utilities and sub-vitamins)
 5. Design variants - different arm lengths, motor sizes, etc
    * How to incorporate design variants - machine files, assemblies, printed parts, cut parts
    * Assembly guide implications
 6. Publishing, collaboration and maintenance
    * Using github, accessing docs
    * Collaboration best practises (inc dropbox)
    * Troubleshooting (esp the build process)
