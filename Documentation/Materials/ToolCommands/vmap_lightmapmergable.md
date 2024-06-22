# Material Command List {#mat_commands}

### vmap_lightmapmergable
#### Syntax

**vmap_lightmapMergable**

#### Overview

When specified, the compiler will attempt to merge all surfaces using
this material together onto lightmap sheets. This can drastically reduce
the artifacts occuring on surfaces like terrain where precision issues
might get you black spots along the lightmap seams. Definitely use this
across large collections of surfaces on which you expect smooth
transitions.