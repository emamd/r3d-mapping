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


# we done
rgl::rgl.close()

# Show the intersection between land and water - this one shows bathymetry
montereybay %>%
  sphere_shade() %>%
  plot_3d(montereybay, water = TRUE, waterlinecolor = "white",
          theta = -45, zoom = 0.9, windowsize = c(1000,1000),zscale = 50)
render_snapshot(title_text = "Monterey Bay, California", 
                title_color = "white", title_bar_color = "black")

# here show the water at 100 meters below sea level
render_water(montereybay, zscale = 50, waterdepth = -100, 
             waterlinecolor = "white", wateralpha = 0.7)
render_snapshot(title_text = "Monterey Bay, California (water level: -100 meters)", 
                title_color = "white", title_bar_color = "black")

# water level at 30 meters above sea level
render_water(montereybay, zscale = 50, waterdepth = 30, 
             waterlinecolor = "white", wateralpha = 0.7)
render_snapshot(title_text = "Monterey Bay, California (water level: 30 meters)", 
                title_color = "white", title_bar_color = "black")


rgl::rgl.close()


# you can slice the data as well, 
# in this case only showing everything below sea level
mont_bathy = montereybay
mont_bathy[mont_bathy >= 0] = NA

montereybay %>%
  sphere_shade() %>%
  add_shadow(ray_shade(mont_bathy,zscale = 50, sunaltitude = 15, lambert = FALSE),0.5) %>%
  plot_3d(mont_bathy, water = TRUE, waterlinecolor = "white",
          theta = -45, zoom = 0.9, windowsize = c(1000,1000))

render_snapshot(title_text = "Monterey Bay Canyon", 
                title_color = "white", 
                title_bar_color = "black")

# clear the renderer
rgl::rgl.clear()


# now show everything above sea level
mont_topo = montereybay
mont_topo[mont_topo < 0] = NA

montereybay %>%
  sphere_shade() %>%
  add_shadow(ray_shade(mont_topo, zscale = 50, sunaltitude = 15, lambert = FALSE),0.5) %>%
  plot_3d(mont_topo, shadowdepth = -50, 
          theta = 135, zoom = 0.9, windowsize = c(1000,1000))

render_snapshot(title_text = "Monterey Bay (sans water)", 
                title_color = "white", 
                title_bar_color = "black")

rgl::rgl.clear()


# you can also cut the data into different shapes! in this case we're doing a hexagon
# so you can make your own r-based settlers of cataan
montereybay %>%
  sphere_shade() %>%
  add_shadow(ray_shade(montereybay,zscale = 50,sunaltitude = 15,lambert = FALSE),0.5) %>%
  plot_3d(montereybay, water = TRUE, waterlinecolor = "white", baseshape = "hex",
          theta = -45, zoom = 0.7, windowsize = c(1000,1000), 
          shadowcolor = "#4e3b54", background = "#f7e8fc")

render_snapshot(title_text = "Monterey Bay Canyon, Hexagon",  vignette = TRUE,
                title_color = "white", title_bar_color = "black", clear = TRUE)


# here you can carve the data into a circle
montereybay %>%
  sphere_shade() %>%
  add_shadow(ray_shade(montereybay,zscale = 50,sunaltitude = 15,lambert = FALSE),0.5) %>%
  plot_3d(montereybay, water = TRUE, waterlinecolor = "white", baseshape = "circle",
          theta = -45, zoom = 0.7, windowsize = c(1000,1000),
          shadowcolor = "#4f3f3a", background = "#ffeae3")

render_snapshot(title_text = "Monterey Bay Canyon, Circle",
                title_color = "white", title_bar_color = "black", clear = TRUE)

# making movies now! 
# The default setting will set the camera to orbit around the center
montereybay %>%
  sphere_shade() %>%
  plot_3d(montereybay, water = TRUE, waterlinecolor = "white",
          theta = -45, zoom = 0.9, windowsize = c(600,600))

#Orbit will start with current setting of phi and theta
render_movie(filename = "montbay.mp4", title_text = 'render_movie(type = "orbit")', 
             phi = 30 , theta = -45)

# this goes back and forth between an angle
render_movie(filename = "montbayosc.mp4", phi = 30 , theta = -90, type = "oscillate",
             title_text = 'render_movie(type = "oscillate")', title_color = "black")

# I think this dumps the previous variables
unlink("montbay.mp4")
unlink("montbayosc.mp4")

# you can also set up custom easing functions
ease_function = function(beginning, end, steepness = 1, length.out = 180) {
  single = (end) + (beginning - end) * 1/(1 + exp(seq(-10, 10, length.out = length.out)/(1/steepness)))
  single
}

zoom_values = c(ease_function(1,0.3), ease_function(0.3,1))

# The above will generate a zoom that looks like this:
ggplot(data.frame(x=1:360, y=zoom_values),) +
  geom_line(aes(x=x, y=y), color="red", size=2) +
  ggtitle("Zoom value by frame")

render_movie(filename="montbaycustom.mp4", type="custom", 
             phi = 30 + 15 * sin(1:360 * pi / 180),
             theta = -45 - 1:360,
             zoom = zoom_values)

rgl::rgl.clear()

# now I'm just having fun because I really liked the hex
montereybay %>%
  sphere_shade() %>%
  add_shadow(ray_shade(montereybay,zscale = 50,sunaltitude = 15,lambert = FALSE),0.5) %>%
  plot_3d(montereybay, water = TRUE, waterlinecolor = "white", baseshape = "hex",
          theta = -45, zoom = 0.7, windowsize = c(1000,1000), 
          shadowcolor = "#4e3b54", background = "#f7e8fc")

render_movie(filename="montbaycustom-hex.mp4", type="custom", 
             phi = 30 + 15 * sin(1:360 * pi / 180),
             theta = -45 - 1:360,
             zoom = zoom_values)

rgl::rgl.close()
unlink("montbaycustom-hex.mp4")

# vary the water depth in each call creating animated features in the movie
# Run all of the below lines through the call to unlink in one block
montereybay %>%
  sphere_shade(texture="desert") %>%
  plot_3d(montereybay, windowsize=c(600,600),
          shadowcolor="#222244", background="lightblue")

render_camera(theta=-90, fov=70, phi=30, zoom=0.8)

for (i in 1:60) {
  render_water(montereybay, zscale=50, waterdepth=-60 - 60 * cos(i*pi*6/180),
               watercolor="#3333bb", waterlinecolor="white", waterlinealpha=0.5)
  render_snapshot(filename=glue::glue("iceage{i}.png"), title_size=30, instant_capture=TRUE,
                  title_text = glue::glue("Sea level: {round(-60 - 60 *cos(i*pi*6/180),1)} meters"))
}

av::av_encode_video(glue::glue("iceage{1:60}.png"), output="custom_movie.mp4", framerate=30)

rgl::rgl.close()

unlink(glue::glue("iceage{1:60}.png"))
unlink("custom_movie.mp4")


# Trying out render_highquality
# this took a looooong time to run on my computer
# decrease the noise by setting the "samples" argument in render_highquality 
# to a higher number (default is 100)
hobart_mat %>%
  sphere_shade(texture="desert") %>%
  add_water(detect_water(hobart_mat), color="desert") %>%
  plot_3d(hobart_mat, zscale=10)
render_highquality()

# `sphere()` and `diffuse()` are rayrender functions
# adds a glowing sphere to the image
# again, this takes a LONG time to run
render_highquality(light=FALSE, 
                   scene_elements=sphere(
                     y=150, radius = 30, material = diffuse(
                       lightintensity = 40, implicit_sample = TRUE
                       )
                     )
                   )

rgl::rgl.close()

# now with Monterey Bay
montereybay %>%
  sphere_shade() %>%
  plot_3d(montereybay, zscale = 50, water = TRUE)

render_camera(theta = -45, zoom = 0.7, phi = 30,fov = 70)
render_highquality(lightdirection = 100, lightaltitude = 45, lightintensity = 800,
                   clamp_value = 10, title_text = "Monterey Bay, CA", 
                   title_color = "white", title_bar_color = "black")


rgl::rgl.close()
