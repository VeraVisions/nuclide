# Materials: Commands {#mat_commands}
## alphafunc
### Syntax

**alphaFunc <func>**

### Overview

Determines the alpha test function used when rendering this surface.

Valid values are **GT0**, **LT128**, and **GE128**. These correspond to
**"GREATER THAN 0"**, **"LESS THAN 128"**, and **"GREATER THAN OR EQUAL
TO 128"**.

This function is used when determining if a pixel should be written to
the frame-buffer. For example, if **GT0** is specified, the only the
portions of the texture map with corresponding alpha values greater than
zero will be written to the framebuffer. **By default alpha testing is
disabled.**

Both alpha testing and normal [alpha
blending](blendFunc) can be used to get
textures that have see-through parts. The difference is that
**alphaFunc** is an all-or-nothing test, while blending smoothly blends
between opaque and translucent at pixel edges.

Alpha test can also be used with
[depthWrite](depthWrite), allowing other
effects to be conditionally layered on top of just the opaque pixels by
setting [depthFunc](depthFunc) to equal.