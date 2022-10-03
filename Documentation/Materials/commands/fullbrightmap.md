# Materials: Commands {#mat_commands}
## fullbrightmap
### Syntax {#syntax}

**fullbrightmap <texturepath/texturename>**

### Overview {#overview}

The texture is essentially a fullbright overlay on top of the
diffuse/albedomap.

Not all [Shaders](Shaders) support them. In some, like the
[unlit](unlit_(Shader)) shader, the
[diffusemap](diffusemap) is always
fullbright.

### See also {#see_also}

-   [diffusemap](diffusemap)
-   [normalmap](normalmap)
-   [specularmap](specularmap)
-   [uppermap](uppermap)
-   [lowermap](lowermap)
-   [reflectmask](reflectmask)
-   [reflectcube](reflectcube)