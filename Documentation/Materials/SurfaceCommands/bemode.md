# Material Command List {#mat_commands}

## bemode {#bemode}

### Syntax

**bemode \<mode\>**

### Overview

Filters which back end rendering features are drawn on top of the material.
While you're not encouraged to be overriding this value, it is sometimes necessary.

### Modes {#bemode_sides}

These are the different modes that we can specify.

#### rtlight {#bemode_rtlight}

All light types will be drawn onto this surface.

#### rtlight_only {#bemode_rtlight_only}

Dynamic lights only.

#### rtlight_smap {#bemode_rtlight_smap}

Shadowmaps only.

#### rtlight_spot {#bemode_rtlight_spot}

Spotlights only.

#### rtlight_cube {#bemode_rtlight_cube}

Cubemap lights only.

#### rtlight_cube_smap {#bemode_rtlight_cube_smap}

Cubemap lights and shadowmaps only.

#### rtlight_cube_spot {#bemode_rtlight_cube_spot}

Cubemap lights and spotlights only.

#### rtlight_spot_smap {#bemode_rtlight_spot_smap}

Spot lights and shadowmaps only.

#### rtlight_cube_spot_smap {#bemode_rtlight_cube_spot_smap}

Cubemap lights, spot lights and shadowmaps only.

#### crepuscular {#bemode_crepuscular}

For skies that might cast rays.

Those are rendered to a frame buffer object (with everything else being [depthdark](@ref bemode_depthdark)) and is then applied to the screen as a post-processing effect.

#### depthonly {#bemode_depthonly}

Used mainly by shadow maps.

#### depthdark {#bemode_depthdark}

Black depth passes only.
Used to draw a black world, when `r_shadow_realtime_world_lightmaps` is `0` for example.

#### gbuffer {#bemode_gbuffer}
#### prelight {#bemode_prelight}

Deferred lighting only.

#### fog {#bemode_fog}

Fog layer only.
