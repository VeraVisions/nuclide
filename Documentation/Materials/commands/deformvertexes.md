# Materials: Commands {#mat_commands}
## deformvertexes
### Syntax

**deformVertexes <func>**

### Overview

This command performs a general deformation on the surface's vertexes,
changing the actual shape of the surface before drawing the shader
passes. You can stack multiple deformVertexes commands to modify
positions in more complex ways, making an object move in two dimensions,
for instance.

### Functions {#functions}

#### wave <siv> <func> <base> <amplitude> <phase> <freq> {#wave}

Designed for water surfaces, modifying the values differently at each
point.

It accepts the standard **wave** functions of the type: **sin**,
**triangle**, **square**, **sawtooth** or **inversesawtooth**.

The "div" parameter is used to control the wave "spread" - a value equal
to the [tessSize](vmap_tessSize) of the
surface is a good default value.

#### normal <siv> <func> <base> &lt;amplitude ~0.1-~0.5&gt; &lt;frequency ~1.0-~4.0&gt; {#normal_amplitude_0.1_0.5_frequency_1.0_4.0}

This deformation affects the normals of a vertex without actually moving
it, which will effect later material options like lighting and
especially environment mapping. If the material stages don't use normals
in any of their calculations, there will be no visible effect.

**Design Notes:** Putting values of 0.1 to 0.5 in Amplitude and 1.0 to
4.0 in the Frequency can produce some satisfying results. Some things
that have been done with it: A small fluttering bat, falling leaves,
rain, flags.

#### bulge <bulgeWidth> <bulgeHeight> <bulgeSpeed> {#bulge}

This forces a bulge to move along the given s and t directions. Designed
for use on curved pipes.

#### move<x> <y> <z> <func> <base> <amplitude> <phase> <freq> {#move}

This keyword is used to make a brush, curve patch or model appear to
move together as a unit. The **<x>** **<y>** and **<z>** values are the
distance and direction in game units the object appears to move relative
to it's point of origin in the map.

The **<func> <base> <amplitude> <phase>** and **<freq>** values are the
same as found in other wave form manipulations.

The product of the function modifies the values x, y, and z.Therefore,
if you have an amplitude of 5 and an x value of 2, the object will
travel 10 units from its point of origin along the x axis. This results
in a total of 20 units of motion along the x axis, since the amplitude
is the variation both above and below the base.

It must be noted that an object made with this material does not
actually change position, it only appears to.

**Design Note**: If an object is made up of surfaces with different
materials, all must have matching deformVertexes move values or **the
object will appear to tear itself apart!**

#### autosprite {#autosprite}

This function can be used to make any given triangle quad (pair of
triangles that form a square rectangle) automatically behave like a
sprite without having to make it a separate entity.

This means that the "sprite" on which the texture is placed will rotate
to always appear at right angles to the player's view as a sprite would.
Any four-sided brush side, flat patch, or pair of triangles in a model
can have the autosprite effect on it. The brush face containing a
texture with this material keyword must be square.

**Design Note**: This is best used on objects that would appear the same
regardless of viewing angle. An example might be a glowing light flare.

#### autosprite2 {#autosprite2}

Is a slightly modified "sprite" that only rotates around the middle of
its longest axis.

This allows you to make a pillar of fire that you can walk around, or an
energy beam stretched across the room.

### Notes {#notes}

Specific parameter definitions for deform keywords:

#### <siv> {#section}

This is roughly defined as the size of the waves that occur. It is
measured in game units. Smaller values create agreater density of
smaller wave forms occurring in a given area. Larger values create a
lesser density of waves, or otherwise put, the appearance of larger
waves. To look correct this value should closely correspond to the value
(in pixels) set for
[tessSize](vmap_tessSize) of the texture.
A value of 100.0 is a good default value (which means your
[tessSize](vmap_tessSize) should be close
to that for things tolook "wavelike").

#### <func> {#section_1}

This is the type of wave form being created. **sin** stands for sine
wave, a regular smoothly flowing wave. **triangle** is a wave with a
sharp ascent and a sharp decay. It will make a choppy looking wave
forms. A **square** wave is simply on or off for the period of the
frequency with no in between. The **sawtooth** wave has the ascent of a
triangle wave, but has the decay cut off sharply like a square wave. An
**inversesawtooth** wave reverses this.

#### <base> {#section_2}

This is the distance, in game units that the apparent surface of the
texture is displaced from the actual surface of the brush as placed in
the editor. A positive value appears above the brush surface. A negative
value appears below the brush surface.

#### <amplitude> {#section_3}

The distance that the deformation moves away from the base value. See
Wave Forms in the introduction for a description of amplitude. <phase>
SeeWave Forms in the introduction for a description of phase)

#### <frequency> {#section_4}

See Wave Forms in the introduction for a description of frequency)

Design Note: The siv and amplitude parameters, when used in conjunction
with liquid volumes like water should take into consideration how much
the water will be moving. A large ocean area would have have massive
swells (big siv values) that rose and fell dramatically (big amplitude
values). While a small, quiet pool may move very little.