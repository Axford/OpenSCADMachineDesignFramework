#!/usr/bin/env python
#
# OpenSCAD produces randomly ordered STL files so source control like GIT can't tell if they have changed or not.
# This scrip orders each triangle to start with the lowest vertex first (comparing x, then y, then z)
# It then sorts the triangles to start with the one with the lowest vertices first (comparing first vertex, second, then third)
# This has no effect on the model but makes the STL consistent. I.e. it makes a canonical form.
#

from __future__ import print_function

import sys
import math

def sqr(x):
    return x * x

class Vertex:
    def __init__(self, x, y, z):
        self.x, self.y, self.z = x, y, z
        self.key = (float(x), float(y), float(z))
        
    def to_floats(self):
        self.x = float(self.x)
        self.y = float(self.y)
        self.z = float(self.z)

class Normal:
    def __init__(self, dx, dy, dz):
        self.dx, self.dy, self.dz = dx, dy, dz

class Facet:
    def __init__(self, normal, v1, v2, v3):
        self.normal = normal
        if v1.key < v2.key:
            if v1.key < v3.key:
                self.vertices = (v1, v2, v3)    #v1 is the smallest
            else:
                self.vertices = (v3, v1, v2)    #v3 is the smallest
        else:
            if v2.key < v3.key:
                self.vertices = (v2, v3, v1)    #v2 is the smallest
            else:
                self.vertices = (v3, v1, v2)    #v3 is the smallest

    def key(self):
        return (self.vertices[0].x, self.vertices[0].y, self.vertices[0].z,
                self.vertices[1].x, self.vertices[1].y, self.vertices[1].z,
                self.vertices[2].x, self.vertices[2].y, self.vertices[2].z)

class STL:
    def __init__(self, fname):
        self.facets = []

        f = open(fname)
        words = [s.strip() for s in f.read().split()]
        f.close()

        if words[0] == 'solid' and words[1] == 'OpenSCAD_Model':
            i = 2
            while words[i] == 'facet':
                norm = Normal(words[i + 2],  words[i + 3],  words[i + 4])
                v1   = Vertex(words[i + 8],  words[i + 9],  words[i + 10])
                v2   = Vertex(words[i + 12], words[i + 13], words[i + 14])
                v3   = Vertex(words[i + 16], words[i + 17], words[i + 18])
                i += 21
                self.facets.append(Facet(norm, v1, v2, v3))

            self.facets.sort(key = Facet.key)
        else:
            print("Not an OpenSCAD ascii STL file")
            sys.exit(1)

    def write(self, fname):
        f = open(fname,"wt")
        print('solid OpenSCAD_Model', file=f)
        for facet in self.facets:
            print('  facet normal %s %s %s' % (facet.normal.dx, facet.normal.dy, facet.normal.dz), file=f)
            print('    outer loop', file=f)
            for vertex in facet.vertices:
                print('      vertex %s %s %s' % (vertex.x, vertex.y, vertex.z), file=f)
            print('    endloop', file=f)
            print('  endfacet', file=f)
        print('endsolid OpenSCAD_Model', file=f)
        f.close()
        
    def AABB(self):
        if len(self.facets) > 0:
            v = self.facets[0].vertices[0]
            bl = Vertex(v.x, v.y, v.z)
            tr = Vertex(v.x, v.y, v.z)
        else:
            bl = Vertex(0,0,0)
            tr = Vertex(0,0,0)    
        
        bl.to_floats()
        tr.to_floats()
            
        for facet in self.facets:
            for vertex in facet.vertices:
                vertex.to_floats()
                
                bl.x = min((bl.x), vertex.x)
                bl.y = min((bl.y), vertex.y)
                bl.z = min((bl.z), vertex.z)
                
                tr.x = max((tr.x), vertex.x)
                tr.y = max((tr.y), vertex.y)
                tr.z = max((tr.z), vertex.z)
            
        return [[bl.x, bl.y, bl.z], [tr.x, tr.y, tr.z]]
        
    def area(self):
        ar = 0;
        
        for facet in self.facets:
            for vertex in facet.vertices:
                vertex.to_floats()
            
            a2 = (   sqr(facet.vertices[1].x - facet.vertices[0].x) + 
                        sqr(facet.vertices[1].y - facet.vertices[0].y) + 
                        sqr(facet.vertices[1].z - facet.vertices[0].z) );
            b2 = (   sqr(facet.vertices[2].x - facet.vertices[1].x) + 
                        sqr(facet.vertices[2].y - facet.vertices[1].y) + 
                        sqr(facet.vertices[2].z - facet.vertices[1].z) );
            c2 = (   sqr(facet.vertices[0].x - facet.vertices[2].x) + 
                        sqr(facet.vertices[0].y - facet.vertices[2].y) + 
                        sqr(facet.vertices[0].z - facet.vertices[2].z) );
            
            ar += 0.25 * math.sqrt( math.fabs(4*a2*b2 - sqr(a2 + b2 - c2)))
            
        return ar;
     
    def volume(self):
        vol = 0;
        
        for facet in self.facets:
            for vertex in facet.vertices:
                vertex.to_floats()
            
            v321 = facet.vertices[2].x * facet.vertices[1].y * facet.vertices[0].z;
            v231 = facet.vertices[1].x * facet.vertices[2].y * facet.vertices[0].z;
            v312 = facet.vertices[2].x * facet.vertices[0].y * facet.vertices[1].z;
            v132 = facet.vertices[0].x * facet.vertices[2].y * facet.vertices[1].z;
            v213 = facet.vertices[1].x * facet.vertices[0].y * facet.vertices[2].z;
            v123 = facet.vertices[0].x * facet.vertices[1].y * facet.vertices[2].z;
            vol +=  (1.0/6.0)*(-v321 + v231 + v312 - v132 - v213 + v123);
            
        return vol;   
    
        
    def info(self):
        # Return aabb, area, volume
        
        return {'aabb': self.AABB(), 'area': self.area(), 'volume': self.volume()}

def canonicalise(fname):
    stl = STL(fname)
    stl.write(fname)
    
    # Return aabb, area, volume
    return stl.info()

if __name__ == '__main__':
    if len(sys.argv) == 2:
        canonicalise(sys.argv[1])
    else:
        print("usage: c14n_stl file")
        sys.exit(1)
