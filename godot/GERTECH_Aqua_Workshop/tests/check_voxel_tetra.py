"""Portable math/face-continuity test for the 6-tetra voxel split.

This tests the algorithm's static geometry, not the Godot runtime or 3D asset
import. Run with: python3 tests/check_voxel_tetra.py
"""
from collections import Counter
from itertools import combinations

CORNERS = (
    (0,0,0), (1,0,0), (0,1,0), (1,1,0),
    (0,0,1), (1,0,1), (0,1,1), (1,1,1),
)
SIX_TETRAS = (
    (0,1,3,7), (0,3,2,7), (0,2,6,7),
    (0,6,4,7), (0,4,5,7), (0,5,1,7),
)

def sub(a,b):
    return tuple(a[i]-b[i] for i in range(3))

def dot(a,b):
    return sum(a[i]*b[i] for i in range(3))

def cross(a,b):
    return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])

def cells_to_tetra(cells):
    result=[]
    for x,y,z in cells:
        corners = [(x+dx,y+dy,z+dz) for dx,dy,dz in CORNERS]
        for tet in SIX_TETRAS:
            result.append(tuple(corners[k] for k in tet))
    return result

def inspect(cells, expected_boundary):
    tetras=cells_to_tetra(cells)
    faces=Counter()
    for t in tetras:
        triple_vol = abs(dot(sub(t[1],t[0]),cross(sub(t[2],t[0]),sub(t[3],t[0]))))
        assert triple_vol==1, (t, triple_vol)
        for face in combinations(t,3):faces[tuple(sorted(face))]+=1
    assert all(c in (1,2) for c in faces.values()), "nonmanifold internal triangle"
    boundary=sum(c==1 for c in faces.values())
    assert boundary==expected_boundary, (boundary,expected_boundary)
    return len(tetras),boundary,len(faces)

assert inspect([(0,0,0)],12)[0]==6
assert inspect([(0,0,0),(1,0,0)],20)[0]==12
assert inspect([(0,0,0),(0,1,0)],20)[0]==12
assert inspect([(0,0,0),(0,0,1)],20)[0]==12
assert inspect([(0,0,0),(1,0,0),(0,1,0)],28)[0]==18  # corner concavity
print("PASS — 6 nondegenerate tetrahedra per occupied voxel")
print("PASS — shared faces conform across x, y and z neighbors")
print("PASS — no nonmanifold triangle or artificial boundary on shared faces")
