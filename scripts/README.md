# Framework Scripts

## Overview

To build all files within the project:

1. Open a terminal and change to the /framework directory
2. Run: ./build.sh



### Build Process

The framework/build.sh script actually calls framework/scripts/build.py, which in turn calls the other scripts in order to:

1. Check machine files (and all included files) for syntax errors
2. Parse the various machine files for BOM information, storing the result in hardware.json
3. Render STL and views for vitamins
4. Render STL and views for printed parts
5. Render views for each assembly step of the various assemblies
6. Render views for each completed machine
7. Generate an assembly guide for each machine, in both markdown and html
8. Generate a documentation index file, also in markdown and html
9. Generate a vitamin catalogue (markdown and html)

The process caches information about the structure of each part, so that only changes are rendered.


### Python Dependencies

You'll need to install the following dependencies to run the full build process:

1. PIL - the Python Image Library - use: pip install pillow
2. Pystache - the Pystache template library - use: pip install pystache

### Other Dependencies

ImageMagick "convert" utility
