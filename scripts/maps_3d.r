source("./scripts/setup.r")

# Download the source DEM file and extract the TIF
loadzip = tempfile() 
download.file("https://dl.dropboxusercontent.com/s/8ltz4j599z4njay/dem_01.tif.zip", loadzip)
hobart_tif = raster::raster(unzip(loadzip, "dem_01.tif"))
unlink(loadzip)

# Convert the TIF to raster format
hobart_mat = raster_to_matrix(hobart_tif)
unlink("dem_01.tif")

# save ambient occlusion data to a variable so it's not recalculated every time
ambientshadows = ambient_shade(hobart_mat)

# plot the 3d map! 
hobart_mat %>%
  sphere_shade() %>%
  add_water(detect_water(hobart_mat), color = "lightblue") %>%
  add_shadow(ray_shade(hobart_mat, sunaltitude = 3, zscale = 33, lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, sunaltitude = 3, zscale = 33), max_darken = 0.7) %>%
  add_shadow(ambientshadows, max_darken = 0.1) %>%
  plot_3d(hobart_mat, zscale = 10, windowsize = c(1000,1000))

# changing background, adding a title, etc.
hobart_mat %>%
  sphere_shade() %>%
  add_water(detect_water(hobart_mat), color = "lightblue") %>%
  add_shadow(ray_shade(hobart_mat, sunaltitude = 3, zscale = 33, lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, sunaltitude = 3, zscale = 33), max_darken = 0.7) %>%
  add_shadow(ambientshadows, max_darken = 0) %>%
  plot_3d(hobart_mat, zscale = 10, windowsize = c(1000,1000), 
          phi = 40, theta = 135, zoom = 0.9, background = "grey30", 
          shadowcolor = "grey5", soliddepth = -50, shadowdepth = -100)

# change initial camera position
render_camera(theta=90, phi=30, zoom=0.7, fov=0)

render_snapshot(title_text = "River Derwent, Tasmania", 
                title_font = "Helvetica", 
                title_size = 50, 
                title_color = "grey90")


render_snapshot(filename = "derwent.png")

#Delete the file
unlink("derwent.png")

# turn off freetype if on Windows
if (.Platform$OS.type == "windows") {
  freetype = FALSE
} else {
  freetype = TRUE
}

# reposition camera
render_camera(theta=120, phi=20, zoom=0.3, fov=90)

# clear any previous labels (in case we're re-running this code)
render_label(clear_previous = TRUE)

# add a label and render the snapshot
render_label(hobart_mat, "River Derwent", textcolor = "white", linecolor = "white", freetype = freetype,
             x = 450, y = 260, z = 1400, textsize = 2.5, linewidth = 4, zscale = 10)
render_snapshot(title_text = "render_label() demo, part 1", 
                title_bar_alpha = 0.8,
                title_bar_color = "white")

# add another label
render_label(hobart_mat, "Jordan River (not that one)", textcolor ="white", linecolor = "white", freetype = freetype,
             x = 450, y = 140, z = 1400, textsize = 2.5, linewidth = 4, zscale = 10, dashed = TRUE)
render_snapshot(title_text = "render_label() demo, part 2", 
                title_bar_alpha = 0.8,
                title_bar_color = "white")

render_camera(zoom = 0.9, phi = 50, theta = -45,fov = 0)
render_snapshot()


# Now let's label mountains
render_label(clear_previous = TRUE)
render_label(hobart_mat, "Mount Faulkner", textcolor ="white", linecolor = "white", freetype = freetype,
             x = 135, y = 130, z = 2500, textsize = 2, linewidth = 3, zscale = 10, clear_previous = TRUE)
render_snapshot()

render_label(hobart_mat, "Mount Dromedary", textcolor ="white", linecolor = "white", freetype = freetype, 
             x = 320, y = 390, z = 1000, textsize = 2, linewidth = 3, zscale = 10)
render_snapshot()

# clear labels
render_label(clear_previous = TRUE, freetype = freetype)
render_snapshot()

# close the render window
rgl::rgl.close()


# what you can do depth of field! 
# Note this and the below lines do not work if you run them all at once (I got an error)
# run them separately and it will work
hobart_mat %>%
  sphere_shade(sunangle = 60) %>%
  add_water(detect_water(hobart_mat), color = "lightblue") %>%
  add_shadow(ray_shade(hobart_mat, sunangle = 60, sunaltitude = 3, zscale = 33, lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(hobart_mat, sunangle = 60, sunaltitude = 3, zscale = 33), max_darken = 0.7) %>%
  add_shadow(ambientshadows, max_darken = 0.1) %>%
  plot_3d(hobart_mat, zscale = 10,windowsize = c(1000,1000), 
          background = "#edfffc", shadowcolor = "#273633")

render_camera(theta = 120, phi = 20, zoom = 0.3, fov = 90)
# 1 is the background, 0 is the foreground
render_depth(focus = 0.8, preview_focus = TRUE)

render_depth(focus=0.81, focallength = 200, title_bar_color = "black", vignette=TRUE, 
             title_text = "The River Derwent, Tasmania", title_color = "white", title_size = 50)


