# Materials: Commands {#mat_commands}
## depthfunc
### Syntax {#syntax}

**depthFunc <func>**

### Overview {#overview}

This controls the depth comparison function used while rendering.

The default is **lequal** (Less than or equal to) where any surface that
is at the same depth or closer of an existing surface is drawn. This is
used for textures with transparency or translucency. Under some
circumstances you may wish to use **equal**, e.g. for light-mapped
grates that are alpha tested (it is also used for mirrors).