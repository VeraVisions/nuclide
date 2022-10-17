# Materials: VMap Commands {#mat_vmap}
## vmap_lightmapsampleoffset
### Syntax

**vmap_lightmapSampleOffset <float>**

### Overview

Takes a single parameter, defaulting to 1.0, which specifies how many
units off a surface should the compiler sample lighting from. Use larger
values (2.0-8.0) if you're getting ugly splotches on lightmapped
terrain. Try to use filtering to solve splotches if possible, leaving
vmap_lightmapSampleOffset as a last resort.