# Material Command List {#mat_commands}

### vmap_backmaterial

#### Syntax

**vmap_backMaterial <material>**

#### Overview

This allows a brush surface to use a different material when you are
inside it looking out.

By way of example, this would allow a water brush (or other) surfaces to
have a different sort order or appearance when seen from the inside.

**vmap_backMaterial** only works on brush faces. For this reason, it is
often deprecated in favor of using
[vmap_cloneMaterial](vmap_cloneMaterial)
where the target material contains
[vmap_invert](vmap_invert).

It can still be useful as a kind of shorthand.