
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/hypertidy/silicate.svg?branch=master)](https://travis-ci.org/hypertidy/silicate) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/hypertidy/silicate?branch=master&svg=true)](https://ci.appveyor.com/project/hypertidy/silicate) [![Coverage Status](https://img.shields.io/codecov/c/github/hypertidy/silicate/master.svg)](https://codecov.io/github/hypertidy/silicate?branch=master)

silicate
========

The goal of silicate is to provide a general common form for complex multi-dimensional data.

The need for this for spatial data is illustrated here:

<http://rpubs.com/cyclemumner/305595>

There are two main motivations for `silicate`:

-   the need for a central common-form of structure data, and a "universal converter"
-   the need for topological primitives for analysis and interaction.

Central to this are the `PATH` and `PRIMITIVE` models, these are dual-views of the two main types of structures used in complex data.

Paths are the turtle-head-down coordinate lists used by lines, polygons, polypath, geom\_line.

Primitives are the edge-lists or triangle-lists or quad-lists used in rgl and in many topological structures. Tthe key thing that makes them topological is a unique-vertex-pool, indexed by other types.

Paths can be partly topological in that a unique vertex pool is indexed by variable-length paths, and this is a key distinction from primitives which have a constant number of indexed vertices per element. There's a clash here, because most efficient for paths is very different from most efficient for primitives.

`silicate` provides an intermediate form for paths, all instances of all coordinates in one table, and another "path" table that records how many of the coordinates (in native order) are used per path. So this is a kind of rle structure, it provides a common model that can be used by any path-based structure for a decomposition or re-composition form.

Key examples
============

the key ones are OSM-like data with names, LiDAR data (xyz multipoints with time, colour, intensity, groupings, etc. - with groupings such as "contiguous surface" - lidR is good for this), animal track data - grouped-multilines with time, depth, temperature etc. on the coordinates, and triangulations - again grouped-structures from rgl

Developer notes.
================

There are key worker functions `sc_coord`, `sc_node`, `sc_object`, `sc_path`.

-   sc\_coord returns the table of coordinates completely flattened, no normalization
-   sc\_object returns the highest level feature metadata
-   sc\_path returns the table of individual paths, with a coordinate count

This generic set of workers is chosen because we often want the complete set of vertices in their pure form. Returning them with no grouping or identifiers and without any de-duplication means we have a representation of the pure geometry. Since the table has no other columns, generic code can be sure that all columns contain a coordinate. That means we don't need specialist code for 'XYZ', 'XYZM', 'XYT', 'TYX' and so on.

The table of individual paths records which object it belongs to, how many coordinates there are and an ID for the path. This is not intended to be 'relational', it's an intermediate form link by pure indexing. Inserting more levels between the paths and the highest objects is possible, but unclear exactly how to do this yet.

The `unjoin` concept is key for mapping the key between unique vertices and a path's instance of those as coordinates, in the right order. We can use the unjoin engine to add structure to other more generic data streams, like GPS, animal tracking, and general sensors.

The model functions `PRIMITIVE` and `PATH` should work in the following cases.

-   to flip from one to another `PRIMITIVE(PATH(PRIMITIVE(x)))` should work for any kind of 'x' model
-   for any `sf` object
-   convert to igraph objects WIP: <https://github.com/mdsumner/scgraph>
-   spatstat objects WIP: <https://github.com/mdsumner/scspatstat>
-   ...

The classes for all variants of simple features are not worked out, for instance a MULTIPOINT can end up with a degenerate (and expensive) segment table.

More functions `sc_uid` provides unique IDs, and `sc_node` is a worker for a arc-node intermediate model.

Intermediate models

-   Arc-node (WIP)
-   Monotone polygons (future work)

Design
------

There is a hierarchy of sorts with layer, object, path, primitives, coordinates, and vertices.

The current design uses capitalized function names `PATH`, `PRIMITIVE` ... that act on layers, while prefixed lower-case function names produce or derive the named entity at a given level for a given input. E.g. `sc_path` will decompose all the geometries in an `sf` layer to the PATH model and return them in generic form. `PATH` will decompose the layer as a whole, including the component geometries.

`PATH()` is the main model used to decompose inputs, as it is the a more general form of the GIS idioms (simple features and georeferenced raster data) This treats connected *paths* as fully-fledged entities like vertices and objects are, creating a relational model that stores all *vertices* in one table, all *paths* in another, and and all highest-level *objects* in another. The PATH model also takes the extra step of *normalizing* vertices, finding duplicates in a given geometric space and creating an intermediate link table to record all *instances of the vertices*. The PATH model does not currently normalize paths, but this is something that could be done, and is close to what arc-node topology is.

The `PRIMITIVE` function decomposes a layer into actual primitives, rather than "paths", these are point, line segment, triangle, tetrahedron, and so on.

Currently `PATH()` and `PRIMITIVE` are the highest level functions to decompose simple features objects.

There are decomposition functions for lower-level `sf` objects organized as `sc_path`, `sc_coord`, and `sc_object`. `sc_path` does all the work, building a simple map of all the parts and the vertex count. This is used to classify the vertex table when it is extracted, which makes the unique-id management for path-vertex normalization much simpler than it was in `gris` or `rangl`.

**NOTE:** earlier versions of this used the concept of "branch" rather than path, so there is some ongoing migration of the use of these words. *Branch* is a more general concept than implemented in geo-spatial systems generally, and so *path* is more accurate We reserve branch for possible future models that are general. A "point PATH" has meaning in the sense of being a single-vertex "path", and so a multipoint is a collection of these degenerate forms. "Path" as a concept is clearly rooted in optimization suited to planar forms, and so is more accurate than "branch".

In our terminology a branch or path is the group between the raw geometry and the objects, and so applies to a connected polygon ring, closed or open linestring, a single coordinate with a multipoint (a path with one vertex). In this scheme a polygon ring and a closed linestring are exactly the same (since they actually are exactly the same) and there are no plane-filling branches, or indeed volume-filling branches. This is a clear limitation of the branch model and it matches that used by GIS.

Exceptions
----------

There are a number of notable exceptions in the spatial world, but unfortunately this highlights how fragemented the landscape is.

TopoJSON, Eonfusion, PostGIS, QGIS geometry generators, Fledermaus, ...

The silicate family

-   [scgraph](https://github.com/hypertidy/scgraph)
-   [scspatstat](https://github.com/hypertidy/scspatstat)

scdb, sctrip, scrgl, scraster, scicosa,
