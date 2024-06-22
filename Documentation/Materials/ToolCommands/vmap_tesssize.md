# Material Command List {#mat_commands}

### vmap_tesssize
#### Syntax

**vmap_tessSize <amount>**

#### Overview

Formely known as just **tessSize**.

The command controls the tessellation size (how finely a surface is
chopped up in to triangles), in game units, of the surface.

This is only applicable to solid brushes, not curves, and is generally
only used on surfaces that are flagged with the
[deformVertexes](deformVertexes) keyword.

Abuse of this can create a huge number of triangles. This happens during
BSP processing, so maps must be reprocessed for changes to take effect.

#### Note {#note}

It can also be used on tesselating surfaces to make sure that
tesselations are large, and thus, less costly in terms of triangles
created.