# Materials: VMap Commands {#mat_vmap}
## vmap_surfacemodel
### Syntax

**vmap_surfaceModel <modelpath> <density> <odds> <minscale> <maxscale>
<minangle> <maxangle> <oriented>**

### Overview

A surface with vmap_surfaceModel in its shader will randomly place a
specified model across it's face. This is designed to place grass or
tree models over terrain.

This will bake the models into the .bsp itself, creating an
unnecessarily inflated map. Use [fte_clutter (Material
Command)](fte_clutter) instead.