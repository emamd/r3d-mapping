source("./scripts/setup.r")

# Download the source DEM file and extract the TIF
loadzip = tempfile() 
download.file("https://dl.dropboxusercontent.com/s/8ltz4j599z4njay/dem_01.tif.zip", loadzip)
hobart_tif = raster::raster(unzip(loadzip, "dem_01.tif"))
unlink(loadzip)

# Convert the TIF to raster format
hobart_mat = raster_to_matrix(hobart_tif)
unlink("dem_01.tif")

# peek at the matrix
hobart_mat[1:10,1:10]

# elevation-to-color mapping
hobart_mat %>%
  height_shade() %>%
  plot_map()

# colored by direction the slope is facing
hobart_mat %>% 
  sphere_shade() %>%
  plot_map()

# detect and add water by looking for flat surfaces
hobart_mat %>%
  sphere_shade() %>%
  add_water(detect_water(hobart_mat)) %>%
  plot_map()

# add a desert color palette
hobart_mat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(hobart_mat), color = "desert") %>%
  plot_map()

# get wacky
hobart_mat %>%
  sphere_shade(texture = "bw") %>%
  add_water(detect_water(hobart_mat), color = "unicorn") %>%
  plot_map()

# try lambertian shading (basic hillshading, doesn't use raytracing)
hobart_mat %>%
  lamb_shade(zscale = 33) %>%
  plot_map()

# it looks inverted!
hobart_mat %>%
  lamb_shade(zscale=33, sunangle=135) %>%
  plot_map()

# flip it and it looks like the original
hobart_mat_inverted = -hobart_mat
hobart_mat %>%
  lamb_shade(zscale = 33) %>%
  plot_map()

# add a layer of shadows to the lamb_shade layer
hobart_mat %>%
  lamb_shade(zscale=33) %>%
  add_shadow(ray_shade(hobart_mat, zscale=33, sunaltitude = 6, lambert = FALSE), 0.3) %>%
  plot_map()

# thanks to raytracing, this is no longer identical
# add a layer of shadows to the lamb_shade layer
hobart_mat_inverted %>%
  lamb_shade(zscale=33, sunangle=135) %>%
  add_shadow(ray_shade(hobart_mat_inverted, zscale=33, sunaltitude = 6, sunangle=135, lambert = FALSE), 0.3) %>%
  plot_map()

# combine everything to make a final 2d map
# default angle: 315 degrees
hobart_mat %>%
  sphere_shade() %>%
  add_water(detect_water(hobart_mat), color="lightblue") %>%
  add_shadow(ray_shade(hobart_mat, zscale = 33, sunaltitude = 5, lambert=FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, zscale = 33, sunaltitude = 5), max_darken = 0.8) %>%
  plot_map()

# try 225 degrees
hobart_mat %>%
  sphere_shade(sunangle = 225) %>%
  add_water(detect_water(hobart_mat), color="lightblue") %>%
  add_shadow(ray_shade(hobart_mat, sunangle = 225, zscale = 33, sunaltitude = 5, lambert=FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, zscale = 33, sunaltitude = 5), max_darken = 0.8) %>%
  plot_map()

# calculate ambient occlusion
hobart_mat %>% 
  ambient_shade() %>%
  plot_map()

# add it to the map from earlier
hobart_mat %>%
  sphere_shade() %>%
  add_water(detect_water(hobart_mat), color="lightblue") %>%
  add_shadow(ray_shade(hobart_mat, zscale = 33, sunaltitude = 5, lambert=FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, zscale = 33, sunaltitude = 5), max_darken = 0.7) %>%
  add_shadow(ambient_shade(hobart_mat), max_darken = 0.1) %>%
  plot_map()






