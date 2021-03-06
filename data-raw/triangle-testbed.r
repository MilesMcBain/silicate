library(sf)
nc <-  st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
library(maptools); data(wrld_simpl)
x <- nc #st_as_sf(wrld_simpl)
## this is internal code of primitives
## used to investigate the fastest ways to build a GC of triangles
## ANSWERE: st_polygon is slow because it does a lot of checking, we don't need any checking to make a triangle POLYGON here
coords <- a.primitives:::objects_as_df(x)
coords[["vertex_"]] <- as.integer(factor(paste(coords[["x"]], coords[["y"]], sep = "-")))
b_link_v <- coords[, c("path_", "vertex_")]
vertices <- coords[!duplicated(b_link_v[["vertex_"]]), c("x", "y", "vertex_")]
vertices <- vertices[order(vertices[["vertex_"]]), ]

segments <- do.call(rbind, lapply(split(b_link_v[["vertex_"]], b_link_v[["path_"]]),
                                  function(x) a.primitives:::path_to_seg(x))
)
## do we need to remove duplicated segments??
bad <- duplicated(cbind(pmin(segments[, 1], segments[, 2]), pmax(segments[, 1], segments[, 2])))
ps <- RTriangle::pslg(P = as.matrix(vertices[, c("x", "y")]), S = segments[!bad, ])
tr <- RTriangle::triangulate(ps)
# this is slow
system.time({
g <- st_sfc(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                   function(x) st_polygon(list(tr$P[c(x, x[1L]), ]))), crs = st_crs(x))
})

## this is not slow
system.time({
  g <- st_sfc(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                     function(x) structure(list(tr$P[c(x, x[1L]), ]), class = c("XY", "POLYGON", "sfg"))), crs = st_crs(x))
})


