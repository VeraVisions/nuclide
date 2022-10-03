# Materials: Commands {#mat_commands}
## diffusemap
### Syntax {#syntax}

**diffusemap <texturepath/texturename>**

### Overview {#overview}

Specifies the default texture asset to use on the diffuse/albedo pass of
the material. This is the base texture in most cases. Some special
materials used for special effects and the like might not have one.
However surfaces such as floors, walls etc. certainly do. It will affect
which texture is used to get color information from for lighting passes,
etc.

### See also {#see_also}

-   [normalmap](normalmap)
-   [specularmap](specularmap)
-   [fullbrightmap](fullbrightmap)
-   [uppermap](uppermap)
-   [lowermap](lowermap)
-   [reflectmask](reflectmask)
-   [reflectcube](reflectcube)