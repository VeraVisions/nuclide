# Materials: Commands {#mat_commands}
## surfaceparm
### Overview

The surfaceparm keyword is not only read by the VMAP compiler, but also
by the renderer. A few keywords will only apply to any one of them.

All surfaceparm keywords are preceded by the word surfaceparm as
follows:

:

    :   surfaceparm **fog**

### Behaviour Keywords {#behaviour_keywords}

Commands that affect core functionality of a surface, or could impact
the entire room or the gameplay surrounding it.

#### areaportal {#areaportal}

A brush marked with this keyword functions as an area portal, a break in
the VMAP tree. It is typically placed on a very thin brush placed inside
a door entity (but is not a part of that entity). The intent is to block
the game from processing surface triangles located behind it when the
door is closed. It is also used by the BSPC (bot area file creation
compiler) in the same manner as a clusterportal. The brush must touch
all the structural brushes surrounding the areaportal.

#### clusterportal {#clusterportal}

A brush marked with this keyword function creates a subdivision of the
area file (.aas) used by the bots for navigation. It is typically placed
in locations that are natural breaks in a map, such a sentrances to
halls, doors, tunnels, etc. The intent is keep the bot from having to
process the entire map at once. As with the the areaportal parameter,
the affected brush must touch all the structural brushes surrounding the
areaportal.

#### donotenter {#donotenter}

Read as "do not enter." Like clusterportal, this is a bot-only property.
A brush marked with donotenter will not affect non-bot players, but bots
will not enter it. It should be used only when bots appear to have
difficulty navigating around some map features.

#### lava {#lava}

Assigns to the texture the game properties set for lava. This affects
both the surface and the content of a brush.

#### nodamage {#nodamage}

The player takes no damage if he falls onto a texture with this
surfaceparm

#### nosteps {#nosteps}

The player makes no sound when walking on this texture.

#### nonsolid {#nonsolid}

This attribute indicates a brush, which does not block the movement of
entities in the game world. It applied to triggers, hint brushes and
similar brushes. This affects the content of a brush.

#### origin {#origin}

Used on the "origin" texture. Rotating entities need to contain an
origin brush in their construction. The brush must be rectangular (or
square). The origin point is the exact center of the origin brush.

#### playerclip {#playerclip}

Blocks player movement through a nonsolid texture. Other game world
entities can pass through a brush marked playerclip. The intended use
for this is to block the player but not block projectiles like rockets.

#### slick {#slick}

This surfaceparm included in a texture should give it significantly
reduced friction.

#### slime {#slime}

Assigns to the texture the game properties for slime. This affects both
the surface and the content of a brush.

#### structural {#structural}

This surface attribute causes a brush to be seen by the VMAP process as
a possible break-point in a BSP tree. It is used as a part of the
material for the "hint" texture. Generally speaking, any opaque texture
not marked as "detail" is, by default, structural, so you shouldn't need
to specify this.

#### water {#water}

Assigns to the texture the game properties for water.

#### climb {#climb}

Marks the desired surface as a climbable surface. This currently affects
the entire volume.

#### vehicleclip {#vehicleclip}

Blocks all movement of vehicle entities through this surface.

#### leakssteam {#leakssteam}

When this surface is impacted, steam will leak out temporarily. Specific
to The Wastes 1.3.

#### leakswater {#leakswater}

When this surface is impacted, water will leak out temporarily. Specific
to The Wastes 1.3.

#### fl_r1 {#fl_r1}

Reserved for custom games. This can be anything.

#### fl_r2 {#fl_r2}

Reserved for custom games. This can be anything.

#### fl_r3 {#fl_r3}

Reserved for custom games. This can be anything.

#### fl_r4 {#fl_r4}

Reserved for custom games. This can be anything.

#### fl_r5 {#fl_r5}

Reserved for custom games. This can be anything.

#### fl_r6 {#fl_r6}

Reserved for custom games. This can be anything.

#### fl_r7 {#fl_r7}

Reserved for custom games. This can be anything.

### Rendering Keywords {#rendering_keywords}

Commands that affect rendering of a surface, or the how surfaces are
made to look by the compiler. These do not affect gameplay function.

#### alphashadow {#alphashadow}

This keyword applied to a texture on a brush, patch or model will cause
the lighting phase of the VMAP process to use the texture's alpha
channel as a mask for casting static shadows in the game world.

Design Note: Alphashadow does not work well with fine line detail on a
texture. Fine lines may not cast acceptable shadows. It appears to work
best with well-defined silhouettes and wider lines within the texture.
Most of our tattered banners use this to cast tattered shadows.

#### fog {#fog}

Fog defines the brush as being a "fog" brush. This is a VMAP function
that chops and identifies all geometry inside the brush. The General
material keyword fogparms must also be specified to tell how to draw the
fog.

#### lightfilter {#lightfilter}

Causes the VMAP light stage to use the texture's RGB and alpha channels
to generate colored alpha shadows in the lightmap. For example, this can
be used to create the colored light effect cast by stained glass
windows. This can be used with surfaceparm alphashadow if an alpha is to
be respected.

#### nodlight {#nodlight}

Read as "No DeeLight". A texture containing this parameter will not be
affected or lit by dynamic lights, such as weapon effects. The VMAP
compiler doesn't really care about this, but the renderer does.

#### nodraw {#nodraw}

A texture marked with nodraw will not visually appear in the game world.
Most often used for triggers, clip brushes, origin brushes, and so on.
Light will pass through it, therefore beware of bleeding issues when
using nodraw/caulk textures with this.

#### nodraw2 {#nodraw2}

Same as nodraw, but the engine won't draw it, whereas the VMAP compiler
will react to the surface. So unlike nodraw, light will not pass through
these surfaces.

#### noimpact {#noimpact}

World entities will not impact on this texture. No explosions occur when
projectiles strike this surface and no marks will be left on it. Sky
textures are usually marked with this texture so those projectiles will
not hit the sky and leave marks.

#### nomarks {#nomarks}

Projectiles will explode upon contact with this surface, but will not
leave marks. Blood will also not mark this surface. This is useful to
keep lights from being temporarily obscured by battle damage.

Blob shadows (aka **r_shadows 1**) also counts as a mark. So any surface
that you don't want to see affected by shadows should receive this
surfaceparm.

#### nolightmap {#nolightmap}

This texture does not have a lightmap phase. It is not affected by the
ambient lighting of the world around it. It does not require the
addition of an rgbGen identity keyword in that stage.

#### trans {#trans}

Light will pass through this surface, but only if either alphashadow or
lightfilter are applied. Tells VMAP that pre-computed visibility should
not be blocked by this surface. Generally, any materials that have
blendfuncs should be marked as surfaceparm trans.

### Material Related Keywords {#material_related_keywords}

Specifies which impact effects and footstep sounds are played when
interacting with a given surface. Only one of them can be given at once:

#### alien {#alien}

Defines that the surface is of an 'alien' material. Affects impact sound
and effects.

#### flesh {#flesh}

Defines that the surface is of flesh. Affects impact sound and effects.

#### foliage {#foliage}

Defines that the surface is foliage. Affects impact sound and effects.

#### computer {#computer}

Defines that the surface is of computer parts. Affects impact sound and
effects.

#### dirt {#dirt}

Defines that the surface is of dirt. Affects impact sound and effects.

#### vent {#vent}

Defines that the surface is a vent. Affects impact sound and effects.

#### grate {#grate}

Defines that the surface is a grate. Affects impact sound and effects.

#### metal {#metal}

Defines that the surface is of metal. Affects impact sound and effects.

#### glass {#glass}

Defines that the surface is of glass. Affects impact sound and effects.

#### sand {#sand}

Defines that the surface is of sand. Affects impact sound and effects.

#### slosh {#slosh}

Defines that the surface is of a liquid. Affects impact sound and
effects.

#### snow {#snow}

Defines that the surface is of snow. Affects impact sound and effects.

#### tile {#tile}

Defines that the surface is of kitchen/bathroom tiles. Affects impact
sound and effects.

#### wood {#wood}

Defines that the surface is of wood. Affects impact sound and effects.

#### concrete {#concrete}

Defines that the surface is of concrete. Affects impact sound and
effects.