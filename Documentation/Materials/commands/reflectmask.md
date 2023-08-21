# Materials: Commands {#mat_commands}
## reflectmask
### Syntax

**reflectmask <texturepath/texturename>**

### Overview

Defines a texture that specifies which parts of a material will reveal a
reflective material, such as a
[cubemap](reflectcube.md). This applies to
standard FTEQW. In Nuclide the reflectmask is currently unused with the
included shaders. If you want to apply reflectivity to your materials,
use the alpha channel of your
[normalmap](normalmap.md) instead.

### See also {#see_also}

-   [diffusemap](diffusemap.md)
-   [normalmap](normalmap.md)
-   [specularmap](specularmap.md)
-   [fullbrightmap](fullbrightmap.md)
-   [uppermap](uppermap.md)
-   [lowermap](lowermap.md)
-   [reflectcube](reflectcube.md)