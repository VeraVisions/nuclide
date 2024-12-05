# Material Command List {#mat_commands}

## vmap_lightsubdivide
### Syntax

**q3map_lightSubdivide \<units\>**

### Overview

Used on surface lights (see [vmap_surfaceLight (Material Command)](@ref vmap_surfaceLight)). Controls
the distance between surface generated light sources for uniform
lighting. It defaults to 120 game units, but can be made larger or
smaller as needed (for light surfaces at the bottom of cracks, for
example). This can be a dominant factor in processing time for lightmap
generation.
