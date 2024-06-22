# Material Command List {#mat_commands}

### fogParms {#fogParms}

#### Syntax

**fogParms <red value> <green value> <blue value> <distance to opaque>**

#### Overview

**Note**: you must also specify "surfaceparm fog" to cause
[vmap](vmap.md) to identify the surfaces inside the volume.
Fogparms only describes how to render the fog on the surfaces.

**red value, green value, blue value**: These are normalized values.
To obtain the values that define fog color divide the desired color's
Red, Green and Blue values by 255 to obtain three normalized numbers
within the 0.0 to 1.0 range.

**distance to opaque**: This is the distance, in game units, until the
fog becomes totally opaque, as measured from the point of view of the
observer. By making the height of the fog brush shorter than the
distance to opaque, the apparent density of the fog can be reduced
(because it never reaches the depth at which full opacity occurs).

#### Notes {#notes}

-   The fog volume can only have one surface visible (from outside the
    fog).
-   Fog must be made of one brush. It cannot be made of adjacent
    brushes.
-   Fog brushes must be axial. This means that only square or
    rectangular brushes may contain fog, and those must have their edges
    drawn along the axes of the map grid (all 90 degree angles).

**Design Notes:**

-   If a water texture contains a fog parameter, it must be treated as
    if it were a fog texture when in use.
-   If a room is to be filled completely with a fog volume,it can only
    be entered through one surface (and still have the fog function
    correctly).
-   Additional shader passes may be placed on a fog brush, as with other
    brushes.