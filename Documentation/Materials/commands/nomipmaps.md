# Materials: Commands {#mat_commands}
## nomipmaps
### Syntax

**noMipmaps**

### Overview

This implies [noPicMip](nopicmip.md), but
also prevents the generation of any lower resolution mipmaps for use by
the 3d card. This will cause the texture to alias when it gets smaller,
but there are some cases where you would rather have this than a blurry
image. Sometimes thin slivers of triangles force things to very low
mipmap levels, which leave a few constant pixels on otherwise scrolling
special effects.