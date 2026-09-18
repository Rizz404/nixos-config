-----------------------
---- ANIMATIONS  ----
---- Preset: Smooth ----
-----------------------
hl.curve("easeOutQuint", {
    type = "bezier",
    points = {{0.23, 1}, {0.32, 1}}
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {{0.65, 0.05}, {0.36, 1}}
})

-- Spring dipakai buat window - kesan "settle" halus, bukan cuma ease linear
hl.curve("easy", {
    type = "spring",
    mass = 1,
    stiffness = 71.2633,
    dampening = 15.8273644
})

hl.animation({
    leaf = "global",
    enabled = true,
    speed = 10,
    bezier = "default"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5.39,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    spring = "easy"
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    spring = "easy",
    style = "popin 80%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutCubic",
    style = "popin 80%"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 2.2,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.5,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3.81,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "easeOutQuint",
    style = "fade"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 2.2,
    bezier = "easeInOutCubic",
    style = "fade"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2.3,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2,
    bezier = "easeInOutCubic"
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 3.2,
    bezier = "easeOutQuint",
    style = "slide"
})
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 7,
    bezier = "easeOutQuint"
})
