# Materials: Commands {#mat_commands}
## reflectmask
### Syntax {#syntax}

**reflectmask <texturepath/texturename>**

### Overview {#overview}

Defines a texture that specifies which parts of a material will reveal a
reflective material, such as a
[cubemap](reflectcube). This applies to
standard FTEQW. In Nuclide the reflectmask is currently unused with the
included shaders. If you want to apply reflectivity to your materials,
use the alpha channel of your
[normalmap](normalmap) instead.

### See also {#see_also}

-   [diffusemap](diffusemap)
-   [normalmap](normalmap)
-   [specularmap](specularmap)
-   [fullbrightmap](fullbrightmap)
-   [uppermap](uppermap)
-   [lowermap](lowermap)
-   [reflectcube](reflectcube)