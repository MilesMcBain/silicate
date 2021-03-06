context("path-decomposition")
#library(sf)
#nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
data("sfzoo")
data("sfgc")
test_that("raw geometry decomposition works", {
  dplyr::bind_rows(lapply(sfzoo, sc_path)) %>% 
  expect_s3_class("tbl_df") %>% 
    expect_named(c("nrow", "ncol", "type", "path_", "subobject"))
})
#nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
inner_cascade <- function(x) {
  tabnames <- join_ramp(x)
  tab <- x[[tabnames[1]]]
  for (ni in tabnames[-1L]) tab <- dplyr::inner_join(tab, x[[ni]])
  tab
}
#nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
test_that("geometrycollection decomposition works", {
  dplyr::bind_rows(lapply(sfgc, sc_path)) %>% 
  expect_s3_class("tbl_df") %>% 
    expect_named(c("nrow", "ncol", "type", "path_", "subobject"))
})

#nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
test_that("sf decomposition works", {
  PATH(minimal_mesh) %>% 
    expect_s3_class("PATH") %>% 
    expect_named(c("object", "path", "vertex", "path_link_vertex"))
})
#nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
test_that("joins are valid", {
  PATH(minimal_mesh) %>% inner_cascade() %>% 
    expect_s3_class("tbl_df")
})
obj <- polymesh
test_that("object and path names as expected", {
   gibble::gibble(obj) %>% expect_named(c("nrow", "ncol", "type", "subobject", "object"))
   expect_true("layer" %in%                              names(sc_object(obj)))
   expect_true(all(c("arc_", "vertex_") %in%               names(sc_arc(obj))))
   expect_true(all(c("x_", "y_") %in%                      names(sc_coord(obj))))
   expect_true(all(c(".vertex0", ".vertex1", "edge_") %in% names(sc_edge(obj))))
   expect_equal("vertex_",                                       names(sc_node(obj)))
   expect_true(all(c("object_", "path_", "ncoords_") %in%  names(sc_path(obj))))
   expect_true(all(c(".vertex0", ".vertex1", 
                     "path_", "segment_", "edge_") %in%    names(sc_segment(obj)))) 

          
          
}  )
