# Material Command List {#mat_commands}

## tcMod {#tcMod}

### Syntax

**tcMod \<func\> [...]**

### Overview

Specifies how texture coordinates are modified after they are generated.

The valid functions for tcMod are **rotate**, **scale**, **scroll**,
**stretch** and **transform**.

**Transform** is a function generally reserved for use by programmers
who suggest that designers leave it alone.

When using multiple **tcMod** functions during a stage, place the scroll
command last in order, because it performs a mod operation to save
precision, and that can disturb other operations.

Texture coordinates are modified in the order in which **tcMods** are
specified. In otherwords, if you see:

```
	tcMod scale 0.5 0.5
	tcMod scroll 1 1
```

Then the texture coordinates will be **scaled** then **scrolled**.

### Functions 

#### rotate <degrees per per second>

This keyword causes the texture coordinates to rotate. The value is
expressed in degrees rotated each second. A positive value means
clockwise rotation. A negative value means counterclockwise rotation.
For example "tcMod rotate 5" would rotate texture coordinates 5 degrees
each second in a clockwise direction. The texture rotates around the
center point of the texture map, so you are rotating a texture with a
single repetition, be careful to center it on the brush (unless
off-center rotation is desired).

#### scale <sScale> <tScale>

Resizes (enlarges or shrinks) the texture coordinates by multiplying
them against the given factors of <sScale> and &lt;tScale). The values
"s" and "t" conform to the "x" and "y" values (respectively) as they are
found in the original texture. The values for sScale and tScale are
**NOT** normalized. This means that a value greater than 1.0 will
increase the size of the texture. A positive value less than one will
reduce the texture to a fraction of its size and cause it to repeat
within the same area as the original texture (Note: see
[clampmap](clampmap) for ways to control
this).

Example: `tcMod scale 0.5 2` would cause the texture to repeat twice
along its width, but expand to twice its height (in which case half of
the texture would be seen in the same area as the original)

#### scroll <sSpeed> <tSpeed>

Scrolls the texture coordinates with the given speeds. The values "s"
and "t" conform to the "x" and "y" values (respectively) as they are
found in the original texture. The scroll speed is measured in
"textures" per second. A "texture" is the dimension of the texture being
modified and includes any previous material modifications to the
original texture). A negative s value would scroll the texture to the
left. A negative t value would scroll the texture down.

Example: tcMod scroll 0.5 -0.5 moves the texture down and right
(relative to the texture's original coordinates) at the rate of a half
texture each second of travel.

**This should be the LAST tcMod in a stage.** Otherwise there maybe
popping or snapping visual effects in some materials.

#### stretch <func> <base> <amplitude> <phase> <frequency>

Stretches the texture coordinates with the given function. Stretching is
defined as stretching the texture coordinate away from the center of the
polygon and then compressing it towards the center of the polygon.

**base**: A base value of one is the original dimension of the texture
when it reaches the stretch stage. Inserting other '''values positive or
negative in this variable will produce unknown effects.

**amplitude**: This is the measurement of distance the texture will
stretch from the base size. It is measured, like scroll, in textures. A
value of 1 here will double the size of the texture at its peak.

**phase**: See the explanation for phase under the deform vertexes
keyword.

**frequency**: this is wave peaks per second.

**func**:

-   **Sin**: the texture expands smoothly to its peak dimension and then
    shrinks smoothly to its valley dimension in a flowing manner.
-   **Triangle**: The textures stretch at a constant rate and spend no
    appreciable time at the peak or valley points.
-   **Square**: The texture is shown at its peak for the duration of the
    frequency and then at its valley for the duration of the frequency.
-   **Sawtooth**: the texture stretches like a triangle wave until it
    reaches a peak, then instantly drops to the valley, as in a square
    wave.
-   **Inversesawtooth**: this is the reverse of the sawtooth wave.

#### transform <m00> <m01> <m10> <m11> <t0> <t1>

Transforms each texture coordinate as follows:

S' = s \* m00 + t \* m10 + t0 T' = s \* m01 + t \* m11 + t1

This is for use by programmers.

#### turb <base> <amplitude> <phase> <freq>

Applies turbulence to the texture coordinate. Turbulence is a back and
forth churning and swirling effect on the texture.

The parameters for this are defined as follows:

-   **base**: Currently undefined.
-   **amplitude**: This is essentially the intensity of the
    disturbance or twisting and squiggling of the texture.
-   **phase**: See the explanation for phase under the
    [deformvertexes](DeformVertexes)
    keyword.
-   **freq**: Frequency. This value is expressed as repetitions or
    cycles of the wave per second. A value of one would cycle once per
    second. A value of 10 would cycle 10 times per second. A value of
    0.1 would cycle once every 10 seconds.
