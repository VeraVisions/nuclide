# Materials: Commands {#mat_commands}
## diffusemap
### Syntax

**diffusemap <texturepath/texturename>**

### Overview

Specifies the default texture asset to use on the diffuse/albedo pass of
the material. This is the base texture in most cases. Some special
materials used for special effects and the like might not have one.
However surfaces such as floors, walls etc. certainly do. It will affect
which texture is used to get color information from for lighting passes,
etc.

### See also {#see_also}

-   [normalmap](Documentation/Materials/commands/normalmap.md)
-   [specularmap](Documentation/Materials/commands/specularmap.md)
-   [fullbrightmap](Documentation/Materials/commands/fullbrightmap.md)
-   [uppermap](Documentation/Materials/commands/uppermap.md)
-   [lowermap](Documentation/Materials/commands/lowermap.md)
-   [reflectmask](Documentation/Materials/commands/reflectmask.md)
-   [reflectcube](Documentation/Materials/commands/reflectcube.md)