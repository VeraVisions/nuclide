# Materials: Commands {#mat_commands}
## blendfunc
![OpenGL blending cheat-sheet](gl_blendmodes.jpg "from zanir.wz.cz/?p=60")

### Syntax

**blendFunc <simplefunc>**

**blendFunc <srcBlend> <destBlend>**

### Overview

Blend functions are the keyword commands that tell the renderer how
graphic layers are to be mixed together.

### Usage

#### Simplified blend functions {#simplified_blend_functions}

The most common blend functions are set up here as simple commands, and
should be used unless you really know what you are doing.

##### add {#add}

This is a shorthand command for `blendFunc GL_ONE GL_ONE`. Effects like
fire and energy are additive.

##### filter {#filter}

This is a shorthand command that can be substituted for either
`blendFunc GL_DST_COLOR GL_ZERO` or `blendFunc GL_ZERO GL_SRC_COLOR`. A
filter will always result in darker pixels than what is behind it, but
it can also remove color selectively. Lightmaps are filters.

##### blend {#blend}

Shorthand for `blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA`. This is
conventional transparency, where part of the background is mixed with
part of the texture.

#### Explicit blend functions {#explicit_blend_functions}

Getting a handle on this concept is absolutely key to understanding all
shader manipulation of graphics.

BlendFunc or "Blend Function" is the equation at the core of processing
shader graphics. The formula reads as follows:

` [Source *`<srcBlend>`] + [Destination * `<dstBlend>`]`

**Source** is usually the RGB color data in a texture file.

**Destination** is the color data currently existing in the frame
buffer.

Rather than think of the entire texture as a whole, it maybe easier to
think of the number values that correspond to a single pixel, because
that is essentially what the computer is processing: One pixel of the
bitmap at a time.

The process for calculating the final look of a texture in place in the
game world begins with the pre-calculated lightmap for the area where
the texture will be located. This data is in the frame buffer. That is
to say, it is the initial data in the Destination. In an unmanipulated
texture (i.e. one without a special shader script), color information
from the texture is combined with the lightmap. In a shader-modified
texture, the $lightmap stage must be present for the lightmap to be
included in the calculation of the final texture appearance.

Each pass or "stage" of blending is combined (in a cumulative manner)
with the color data passed onto it by the previous stage. How that data
combines together depends on the values chosen for the Source Blends and
Destination Blends at each stage. Remember it's numbers that are being
mathematically combined together that are ultimately interpreted as
colors.

A general rule is that any Source Blend other than **GL_ONE** (or
**GL_SRC_ALPHA** where the alpha channel is entirely white) will cause
the Source to become darker.

##### Source Blend <srcBlend> {#source_blend}

The following values are valid for the Source Blend part of the
equation.

-   **GL_ONE** This is the value 1. When multiplied by the Source, the
    value stays the same the value of the color information does not
    change.
-   **GL_ZERO** This is the value 0. When multiplied by the Source, all
    RGB data in the Source becomes Zero (essentially black).
-   **GL_DST_COLOR** This is the value of color data currently in the
    Destination (frame buffer). The value of that information depends on
    the information supplied by previous stages.
-   **GL_ONE_MINUS_DST_COLOR** This is nearly the same as
    **GL_DST_COLOR** except that the value for each component color is
    inverted by subtracting it from one. (,i.e. R = 1.0 - DST.R, G =
    1.0 - DST.G, B = 1.0 - DST.B, etc.)
-   **GL_SRC_ALPHA** The TGA file being used for the Source data must
    have an alpha channel in addition to its RGB channels (for a total
    of four channels). The alpha channel is an 8-bit black and white
    only channel. An entirely white alpha channel will not darken the
    Source.
-   **GL_ONE_MINUS_SRC_ALPHA** This is the same as **GL_SRC_ALPHA**
    except that the value in the alpha channel is inverted by
    subtracting it from one.(i.e. A=1.0 - SRC.A)

##### Destination Blend <dstBlend> {#destination_blend}

The following values are valid for the Destination Blend part of the
equation.

-   **GL_ONE** This is the value 1. When multiplied by the Destination,
    the value stays the same the value of the color information does not
    change.
-   **GL_ZERO** This is the value 0. When multiplied by the Destination,
    all RGB data in the Destination becomes Zero (essentially black).
-   **GL_SRC_COLOR** This is the value of color data currently in the
    Source (which is the texture being manipulated here).
-   **GL_ONE_MINUS_SRC_COLOR** This is the value of color data currently
    in Source, but subtracted from one(i.e. inverted).
-   **GL_SRC_ALPHA The TGA** file being used for the Source data must
    have an alpha channel in addition to its RGB channels (four a total
    of four channels). The alpha channel is an 8-bit black and white
    only channel. An entirely white alpha channel will not darken the
    Source.
-   **GL_ONE_MINUS_SRC_ALPHA** This is the same as **GL_SRC_ALPHA**
    except that the value in the alpha channel is inverted by
    subtracting it from one. (i.e. A=1.0 - SRC.A).

##### Doing the Math: The Final Result {#doing_the_math_the_final_result}

The product of the Source side of the equation is added to the product
of the Destination side of the equation. The sum is then placed into the
frame buffer to become the Destination information for the next stage.
Ultimately, the equation creates a modified color value that is used by
other functions to define what happens in the texture when it is
displayed in the game world.

#### Default Blend Function {#default_blend_function}

If no blendFunc is specified then no blending will take place. That's
just a fact of life.