# Decl/Defs {#scripting}

## Surface Properties {#surfdata}

**Surfaces** are being abstracted into one API with the help of **SurfData**
helper functions and large parts of NSSurfacePropEntity.

### Preface {#surfdata_preface}

#### The problem {#surfdata_problem}

We need to define how a surface, speak a texture-mapped triangle,
behaves when being interacted with.

-   What happens when e.g. a bullet collides with it?
-   What sounds does it make when it collides with other objects?
-   What physical properties does it have that make it special?

#### History {#surfdata_history}

In GoldSrc and similar engines, you'd specify
which material is used through 3 ways:

-   The surface is a map texture, with a short material character
    definition inside `sound/materials.txt` defining what the surface is
    made of. See @ref gsmaterials for details.
-   The entity itself offers a list of materials to choose from for
    impact/breaking properties. For example `func_breakable` has the
    `material` key. Which then tells the rest of the codebase that this
    object will respond like whatever it's defined as.
-   The entity might hard-code what it's made of. For example you could
    say an entity will always be `glass`, or always be `metal`. Level
    designers can't change these.

**In that engine, this attribute merely affected audio visual feedback
like bullet impacts.**

They all sounded the same when it came to physics etc.

Nowadays the artists want more control, they want to decide if an entity
uses special particle effects for impacts, or sounds - the sound it
makes when it scrapes across the floor or gets shaken - the weight of
the object and the friction it deals with.

#### Understanding the new way {#surfdata_understanding_the_new_way}

So in Nuclide, there's a few options too as to how you're able to define
what property anything is made of.

-   For the level geometry, a surfaceprop is used to
    define what material properties to use. There are a lot of basic materials
    to choose from there.
-   Entities can **specify** which entry from
    `scripts/surfaceproperties.txt` get's used. This is required for
    NSPhysicsEntity derived classes.
    Those entities set their `surfdata` or `materialdata` key/value
    field to be the name of an entity listed inside the
    `surfaceproperties.txt` file.
-   ...of course, the old way is supported as long as you're using a
    legacy format that does not support **surfaceprop**. They'll get
    mapped to the IDs specified in the surfaceproperties.txt file.

And instead of defining a single character defining the audio visual
appearance, you can now tweak every aspect of it. See **Scripting**
below.

Also, if an entity does not specify the material character inside the
script, Nuclide will figure it out on a surrounding surfaceparm basis.

### Scripting {#surfdata_scripting}

Scripts are formatted like our soundDefs:

        typename
        {
            key/value pairs
            ...
        }

Available keys are:

        "base"          <string>    what type to inherit
        "gamematerial"      <char>      material character, e.g. W for wood
        "climbable"     <bool>      ???
        "thickness"     <float>     non-solid, air (?) thickness
        "density"       <int>       material density in kg / m^3

        "elasticity"        <float>     0.0 - 1.0 ; soft to hard
        "friction"      <float>     friction multiplier
        "dampening"     <float>     drag multiplier
        "jumpfactor"        <float>     bouncyness?
        "maxspeedfactor"    <float>     maxvelocity?

        "stepleft"      <string>    footstep left
        "stepright"     <string>    footstep right
        "fx_bulletimpact"      <string>    particle effect to cast on impact
        "bulletimpact"      <string>    soundDef to play on impact
        "scraperough"       <string>    soundDef to play on rough scraping
        "scrapesmooth"      <string>    soundDef to play on smooth scraping
        "impacthard"        <string>    soundDef for hard impacts
        "impactsoft"        <string>    soundDef for soft impacts

        "shake"         <string>    sound to play when object is being shaken
        "strain"        <string>    sound to play when object is being strained?
        "break"         <string>    sound to play when object breaks
        "roll/rolling"      <string>    sound to play when object rolls

        none of these are concerning us right now:
        "audioreflectivity" <float>
        "audiohardnessfactor"   <float>
        "audioroughnessfactor"  <float>
        "scrapeRoughThreshold"  <float>
        "impactHardThreshold"   <float>
        "audioHardMinVelocity"  <float>
