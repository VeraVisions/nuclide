# Material Command List {#mat_commands}

## vmap_remapmaterial
### Syntax

**vmap_remapMaterial \<material\>**

### Overview

Allows the material to later become known as the specified material.

These materials should not contain anything but compiler-specific
keywords.

For example, if you want a material that is exactly like the
specified **vmap_remapMaterial** in appearance, but with a
specific **vmap_** instruction or surfaceparm characteristics, use this command.

However, if you want want just a material's vmap_/surfaceparm
properties, use
[vmap_baseMaterial](@ref vmap_baseMaterial).
