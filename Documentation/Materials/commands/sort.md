# Materials: Commands {#mat_commands}
## sort
### Syntax

**sort <value>**

### Overview

Use this keyword to fine-tune the depth sorting of materials as they are
compared against other materials in the game world. The basic concept is
that if there is a question or a problem with materials drawing in the
wrong order against each other, this allows the designer to create a
hierarchy of which materials draws in what order.

The default behavior is to put all blended materials in sort "additive"
and all other materials in sort "opaque", so you only need to specify
this when you are trying to work around a sorting problem with multiple
transparent surfaces in a scene.

### Values {#values}

The value here can be either a numerical value or one of the keywords in
the following list (listed in order of mostly ascending priority):

-   **ripple**: Meant for surfaces blending below water surfaces I
    guess.
-   **eferredlight**: Blend at the same order as deferred lighting. So
    before diffuse mapping usually takes place.
-   **portal**: This surface is a portal, it draws over every other
    shader seen inside the portal, but before anything in the main view.
-   **sky**: Typically, the sky is the farthest surface in the game
    world. Drawing this after other opaque surfaces can be an
    optimization on some cards. This currently has the wrong value for
    this purpose, so it doesn't do much of anything.
-   **opaque**: This surface is opaque (rarely needed since this is the
    default with noblendfunc)
-   **decal**: Blend it like a decal. Ones affected by light, or
    something.
-   **seethrough**: Not sure what to call this, beyond repeating its
    name and it being between decal and unlitdecal.
-   **unlitdecal**: Blend it like an unlit decal, this most commonly is
    bullet impacts.
-   **banner**: Transparent, but very close to walls.
-   **underwater**: Draw behind normal transparent surfaces.
-   **blend**: Draw like a blendFunc blend transparent surface.
-   **additive**: normal transparent surface (default for shaders with
    blendfuncs)
-   **nearest**: this shader should always sort closest to the viewer,
    e.g. muzzle flashes and blend blobs

It is generally recommended you stick to the keywords. The engine may
introduce new ones and you will benefit from internal sorting parameters
not clashing with yours whenever the engine may update them.