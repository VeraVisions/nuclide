# Material Command List {#mat_commands}

## reflectMask {#reflectMask}

### Syntax

**reflectMask \<texturepath/texturename\>**

### Overview

Defines a texture that specifies which parts of a material will reveal a
reflective material, such as a
[cubemap](@ref reflectcube). This applies to
standard FTEQW. In Nuclide the reflectmask is currently unused with the
included shaders. If you want to apply reflectivity to your materials,
use the alpha channel of your
[normalmap](normalmap.md) instead.
