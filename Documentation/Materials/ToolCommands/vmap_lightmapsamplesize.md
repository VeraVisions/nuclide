# Material Command List {#mat_commands}

### vmap_lightmapsamplesize
#### Syntax

**vmap_lightmapSampleSize <int>**

#### Overview

Surfaces using a material with this option will have the pixel size of
the lightmaps set to N world grid units. This option can be used to
produce high-resolution shadows on certain surfaces. In addition, it can
be used to reduce the size of lightmap data, where high-resolution
shadows are not required, gaining memory and performance benefits. The
default sample size is 8, smaller numbers increases lightmap resolution.
In general, you should stick with power of 2 values.