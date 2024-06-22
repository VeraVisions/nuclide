# Material Command List {#mat_commands}

### cull {#cull}

#### Syntax

**cull <side>**

#### Overview

Every surface of a polygon has two sides, a front and a back. Typically,
we only see the front or "out" side. For example, a solid block you only
show the front side. In many applications we see both. For example, in
water, you can see both front and a back. The same is true for things
like grates and screens.

To "cull" means to remove. The value parameter determines the type of
face culling to apply. The default value is cull front if this keyword
is not specified. However for items that should be inverted then the
value back should be used. To disable culling, the value disable or none
should be used. Only one cull instruction can be set for the material.

#### Sides {#cull_sides}

##### front {#cull_front}

**This is the default value.** The front or "outside" of the polygon is
not drawn in the world. It is used if the keyword `"cull "` appears in
the content instructions without a <side> value or if the keyword cull
does not appear at all in the shader.

##### back {#cull_back}

Cull back removes the back or "inside" of a polygon from being drawn in
the world.

##### none {#cull_none}

Neither side of the polygon is removed. Both sides are drawn in the
game. Very useful for making panels or barriers that have no depth, such
as grates, screens, metal wire fences and so on and for liquid volumes
that the player can see from within. Also used for energy fields,
sprites, and weapon effects (e.g. plasma).

**Design Notes:** For things like grates and screens, put the texture
with the cull none property on one face only. On the other faces, use a
non-drawing texture.