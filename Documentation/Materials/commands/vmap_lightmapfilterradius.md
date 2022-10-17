# Materials: VMap Commands {#mat_vmap}
## vmap_lightmapfilterradius
### Syntax

**vmap_lightmapFilterRadius <lightmap filter radius>
<light filter radius>**

### Overview

This is usually used on [light emitting
materials](vmap_surfaceLight) to
approximate finer subdivided lighting. It adds a gaussian blur effect to
the lightmaps of either the material itself, or the surfaces affected by
the material, or both. The values for **<lightmap filter radius>** and
**<light filter radius>** are measured in world units of filtering
(blurring) of lightmap data cast by any light sources.

**<lightmap filter radius>** Amount of blur set for the material itself
to approximate for the [surface
light's](vmap_surfaceLight) finer
subdivided lighting. It should be set to 0 for sky materials since they
don't have lightmaps.

**<light filter radius>**: Amount of blur set for other surfaces
affected by this material's emitted light. It should be set just high
enough to eliminate the "stadium shadow" effect sometimes produced by
[light_environment](light_environment) or to smooth out the
lighting on [surface
lights](vmap_surfaceLight).

[vmap_lightmapFilterRadius](vmap_lightmapFilterRadius)
should be placed before any light related material directives that you
want it to affect.