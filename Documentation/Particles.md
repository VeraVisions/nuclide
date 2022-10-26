# Particles

**Particles**, part of a particle system, are sprites/models in 3D space
that simulate impacts and other chemical reactions. They can be used for
a variety of use cases - most commonly they're used for explosions,
bullet impacts and smoke.

The particle system in **FTEQW** is quite advanced with its
use of a plaintext scripting format.

Particles can be stored inside the default.cfg file of a game/mod, or
into its own **./particles/default.cfg** file when the
console variable **r_particledescr* is set to its
default value and the console variable **r_particlesystem*
is left to the default value **"script"**.

## Syntax {#syntax}

Particles are similar to **Materials** in the way
they are written. However they can be injected into any config file and
have a completely different set of commands.

```
r_part blah {
texture textures/particles/myimage.tga
tcoords 0 0 64 64 64
die 2
scalefactor 1
scale 20
alpha 0.5
rgb 255 0 0
rgbdelta 0 128 128
spawnmode ball
spawnorg 32
}
```

The above example will give transparent (0.5) red particles that will
fade to fully white when they go fully transparent 2 seconds later. They
will spawn within a ball of 32 units radius.

## Commands {#commands}

Types: Always try to include a type. The engine will guess what your
particle is meant to be otherwise, based on textures and other nonsense.
That stuff is generally unreliable, and probably not what you want.

Chaining: You can add multiple particle descriptions to a single effect.
The first should be 'r_part foo', and the others should be 'r_part
+foo'. Particles without a + will reset the chain.

Effect naming: Effects loaded by r_particledesc will be given an
internal prefix, eg: foo.cfg. If the gamecode explicitly states foo.bar,
your foo.cfg will automatically be executed, and will automatically use
the bar effect from it. The effect can still be overriden from a custom
config by explicitly naming the effect foo.bar - the effect bar in the
config foo will not override this, but would override bar on its own.

Scale: scale values are defined in 1/4th qu, for some reason.
scalefactor typically needs to be explicitly set to 1. this value
affects how the particle scales with distance from view, rather than the
actual size of the particle.

### texture <TEXTURENAME> {#texture}

`   specifies to use an image named TEXTURENAME for this effect.`

### shader \[shadername\] \[\n{\nshaderbody\n}\n\] {#shader_shadername_nnshaderbodynn}

`   Specifies to use a named shader.`
`   If shaderbody is included (as a nested block on the following line) then that shader text will be used to create the shader if it doesn't otherwise exist.`
`   This overrides blendmodes, as no default shader will need to be created.`

### tcoords <s1> <t1> <s2> <t2> \[tscale\] \[rsmax\] \[rsstep\] {#tcoords_tscale_rsmax_rsstep}

`   specifies to use a subsection of the image.`
`   if tscale is set, all units are divided by this. it is the virtual size of your texture. So a value of 1 means that your texture coords must be between 0 and 1. But if it properly matches your texture's size, the coords are in pixels.`
`   if rsmax is present, each particle will use a random image. These images must be on a single row in your particle font.`
`   rsstep specifies the stride (gap from one to the next) in your particle font, and is only needed if rsmax is present and greater than 1.`

### atlas count_in_each_axis firstidx \[last\] {#atlas_count_in_each_axis_firstidx_last}

`   An alternative to tcoords.`
`   The specified texture (or shader) is to be considered as a grid of sprites (x*x, where x is specified in that first arg).`
`   firstidx specifies the first image to use (horizontal THEN vertical).`
`   last specifies the last image to use (inclusive). The engine will pick one at random. They should not span multiple rows.`

### rotation <startmin> <startmax> <speedmin> <speedmax> {#rotation}

`   the particle will start with a rotation rotated between startmin and startmax.`
`   It will then rotate with some per-particle value randomly picked between the speedmin+speedmax values.`
`   Should NOT be used on beam particles.`

### beamtexstep <value> {#beamtexstep}

`   only valid if the effect is a beam.`
`   specifies the number of quake units per beam texture repitition.`

### beamtexspeed <value> {#beamtexspeed}

`   only valid if the effect is a beam.`
`   controls how fast the texture scrolls on the beam.`

### scale <min> \[max\] {#scale_max}

`   particles will start with a diameter of this many quake units.`
`   actual scale will be randomly chosen between min and max (max defaults to equal if min is missing)`

### scalefactor <frac> {#scalefactor}

`   controls how the particle scales with distance.`
`   1 makes the particle scale the same as anything else`
`   0 makes the particle not change size no matter how far it is`

### stretchfactor <factor> {#stretchfactor}

`   controls how spark particles stretch according to their velocity.`
`   negative values give fixed length sparks.`

### scaledelta <value> {#scaledelta}

`   controls how the particle scales over time`
`   specifies the change in the particle scale per second.`
`   Due to technical reasons, any decal types are unable to use this parameter.`

### step <min> <max> {#step}

`   trails/beams only`
`   specifies the distance between each particle in the trail (or beam).`

### count <min> <max> {#count}

`   point/box effects only (not trails or beams)`
`   specifies how many particles are spawned per effect (some classic effects contain an extra scaler which is multiplied by the resulting value)`

### alpha <value> {#alpha}

`   specifies the initial alpha value of the effect`

### alpharand <value> {#alpharand}

`   specifies a randomized additonal value added to each particle's initial alpha.`

### alphadelta <value> {#alphadelta}

`   specifies how much the alpha value of the effect changes per second (subtracted)`

### die <maximum age> <minimum age> {#die}

`   specifies the maximum age of the particle`

### randomvel <horiz> \[vert\] {#randomvel_vert}

`   controls how fast the particle moves when it spawns (according to its spawn pattern). This works regardless of any requested velocities.`
`   if vert is not specified, horiz is used instead.`

### veladd <value> {#veladd}

`   controls how much of the effect's spawn velocity is used, can be greater than 1, or negative.`

### orgadd <value> {#orgadd}

`   biases how much to add to the starting origin relative to the requested velocity.`

### orgbias <x> <y> <z> {#orgbias}

`   biases the particle's origin by this absolute worldspace vector, regardless of spawn mode.`

### velbias <x> <y> <z> {#velbias}

`   biases the particle's velocity by this absolute worldspace vector, regardless of spawn mode.`

### orgwrand <x> <y> <z> {#orgwrand}

`   randomised offset for the particle's origin, in worldspace.`

### velwrand <x> <y> <z> {#velwrand}

`   randomised offset for the particle's origin, in worldspace.`

### friction &lt;<xyz>\|<xy> <z> \| <x> <y> <z>&gt; {#friction}

`   Proportion of the particle's speed that should be lost from friction. Negative values are accepted.`

### gravity <value> {#gravity}

`   amount that the particle's velocity changes per second, in quake units.`

### clipbounce <value> {#clipbounce}

`   how much of the particle's velocity to use if the particle is clipped. See cliptype.`
`   Defaults to 0.8`

### cliptype <effectname> {#cliptype}

`   Specifies which new effect to spawn when the particle hits something.`
`   The origin and velocity of the particle are used to spawn the new effect.`
`   The clipbounce value is used as a scaler for the reflected velocity.`
`   If the effect named is the effect itself, the particle will merely bounce, instead of spawning a new effect.`
`   FIXME: make default to bounce if clipbounce is set without cliptype.`

### clipcount <count> {#clipcount}

`   The scaler to use for the number of particles to spawn upon a clip event.`
`   Only valid in conjunction with cliptype.`

### assoc <effectname> {#assoc}

`   Specifies another effect to spawn at the same time that this effect is spawned.`
`   Thus allowing two sets of particles from one effect.`

### notunderwater \[content names\] {#notunderwater_content_names}

`   Specifies that this particle should ONLY be spawned when out of water.`
`   The particle will not spawn under water (this does not affect assoc chains).`
`   Content names are a space-separated list of: water slime lava sky solid fluid. Default is fluid if not specified.`
`   The r_part_contentswitch cvar must be enabled for this to function correctly.`

### underwater \[content names\] {#underwater_content_names}

`   Specifies that this particle should ONLY be spawned when underwater.`
`   The particle will not spawn if the spawn position is non-water (this does not affect assoc chains).`

### citracer {#citracer}

`   only valid if colorindex is set.`
`   adds a palette index between 0 and 3, based on the particle index in the effect or trail.`

### red <value> {#red}

### green <value> {#green}

### blue <value> {#blue}

### rgb <red> <green> <blue> {#rgb}

### rgb <value> {#rgb_1}

### rgbf <red> <green> <blue> {#rgbf}

`   Specifies the initial red, green, and/or blue values for each particle.`
`   Fully opaque is 255 or above.`
`   Values above 255 are valid, but will remain opaque until the value drops below 255 from the `

colour deltas.

`   The rgbf form takes values scaled by 1 instead of 255.`

### redrand <value> {#redrand}

### greenrand <value> {#greenrand}

### bluerand <value> {#bluerand}

### rgbrand <red> <green> <blue> {#rgbrand}

### rgbrand <value> {#rgbrand_1}

### rgbrandf <red> <green> <blue> {#rgbrandf}

`   Specifies how much extra red, green, and/or blue there may be for particles.`
`   The initial colour will be multiplied by this amount before addition.`
`   Each componant is separately randomized. EG, red might  add nothing, while the full green is added, and only half the blue.`
`   Fully opaque is 255 or above.`
`   The rgbrandf form takes values scaled by 1 instead of 255.`

### redrandsync <value> {#redrandsync}

### greenrandsync <value> {#greenrandsync}

### bluerandsync <value> {#bluerandsync}

### rgbrandsync <red> <green> <blue> {#rgbrandsync}

### rgbrandsync <value> {#rgbrandsync_1}

`   Specifies how much extra red, green, and/or blue there may be for particles.`
`   The initial colour will be multiplied by this amount before addition.`
`   Componants are syncronised. EG, if the full amount of red is added, the full amount of green and blue will also be added.`
`   Fully opaque is 255 or above.`

### reddelta <value> {#reddelta}

### greendelta <value> {#greendelta}

### bluedelta <value> {#bluedelta}

### rgbdelta <red> <green> <blue> {#rgbdelta}

### rgbdelta <value> {#rgbdelta_1}

### rgbdeltaf <red> <green> <blue> {#rgbdeltaf}

`   Specifies how much the red, green, and/or blue values of each particle change over time.`
`   The value 255 is the value required to go from opaque to invisible in 1 second.`

### rgbdeltatime <value> {#rgbdeltatime}

`   Specifies for how long the particle may change colours for. After this many seconds, the particle may no longer change colours (delta becomes 0).`

### rampmode <mode> {#rampmode}

`   mode may be one of:`
`   none: uses rgb+rand+sync+delta+scale+scaledelta values.`
`   nearest(or absolute): the ramp overrides all colour+scale values. The effect moves from one absolute ramp index to the next.`
`   lerp: smoothly interpolates from one value to the next.`
`   delta: uses rgb+rand+sync+scale, but not delta values. All delta values come from the colour ramp instead.`

`   if not none, the ramp index used is based upon the particle's age, its lifetime, and how many ramp elements there are.`

### rampindexlist <idx1> \[<idx2> \[idx3 ...\]\] {#rampindexlist_idx3_...}

`   Scale used is the currently set scale value.`
`   Specifies a set of palette index values to use for the effect as part of the effect's colour ramp.`

### rampindex <idx> <scale> {#rampindex}

`   Specifies an individual palette index value and particle scale to use for the effect as part of the effect's colour ramp`

### ramp <red> <green> <blue> \[alpha\] \[scale\] {#ramp_alpha_scale}

`   Specifies a ramp index in rgb terms, regardless of palette.`

### stains <value> {#stains}

`   How much the effect discolours the wall upon impact.`
`   The stained colour is based upon the colour of the particle upon impact.`

### blend <mode> {#blend}

`   If the texture used is actually a shader then that shader's blend mode will take precidence.`
`   As a general rule you should try to use only the premul blend modes (as well as atlasing).`
`   mode may be one of:`

-   adda
-   addc
-   subtract
-   invmoda
-   invmodc
-   blendcolour
-   blendalpha
-   premul_subtract
-   premul_add
-   premul_blend
-   rtsmoke

### spawnmode <mode> \[arg1\] \[arg2\] {#spawnmode_arg1_arg2}

`   This affects how particles are positioned when they first spawn, and their initial velocities.`
`   for point effects, mode may be one of:`
`       box: simple axially aligned box of particles.`
`       circle: particles spawn within a ball with uniform distance from the center. none will appear in the middle.`
`           arg1: percentage of the circle to cover. a value of 5 will go around the circle 5 separate times. this can be used for weird beam effects.`
`           areaspread: the radius of the ball`
`           areaspreadvert: the height of the ball. if 0, will be a flat circle`
`       ball: particles spawn randomly within a ball.`
`           areaspread: the radius of the ball`
`           areaspreadvert: the height of the ball. if 0, will be a flat circle.`
`       telebox: matches quake's telebox`
`       lavasplash: like chthon's lava splash`
`       uniformcircle: particles are spawned in a circle with uniform distance between and from the center. z=0.`
`       syncfield: particles spawn at predictable locations based upon time within a rough sphere. Only useful for effects that are regenerated+replaced every frame.`
`       distball:`
`       *default*: regular box. particles are spawned inside an axially aligned box.`

`   for trail effects, mode may be one of:`
`       spiral: particles are given velocities perpendicular to the direction based on the distance moved.`
`       tracer: particles spawn with alternating horizontal velocities (a wake effect).`
`       *default*: particles spawn as a regular trail.`

### type <mode> {#type}

`   How the particles look.`
`   mode may be:`

-   beam: valid only for trails. Particles form a single textured beam
    acting as nodes along it.
-   spark: particles are lines, their length depending upon their speed.
-   sparkfan: particles are non-planar triangle fans, their length
    depending upon their speed.
-   texturedspark: textured particles are aligned along their direction
    of movement, their length depending upon their speed, width equal to
    their scale.
-   cdecal/decal: particles are spawned only upon bsp geometry. They are
    clipped by it.
-   udecal: unclipped decal. exact semantics are subject to change.
-   normal/\*default\*: Particles are regular, rotating, 2d images.

### clippeddecal <mask> \[match\] {#clippeddecal_match}

`   implies 'type decal'.`
`   The two extra args allow you to spawn these decals ONLY on surfaces with matching surfaceflags.`
`   Separation of mask+match allows you to create many descrete surface types instead of being limited to 32 bits/types.`

### spawntime <value> {#spawntime}

### spawnchance <value> {#spawnchance}

### emit <effectname> {#emit}

`   Specifies the effect to periodically emit.`

### emitinterval <min> {#emitinterval}

`   Particles will not emit additional effects for this duration after emitting one.`

### emitintervalrand <extra> {#emitintervalrand}

`   FIXME: fold into emitinterval`
`   `

### emitstart <seconds> {#emitstart}

`   Prevents the particle from emitting anything for this duration when it first spawns.`

### viewspace \[frac\] {#viewspace_frac}

`   Specifies that this particle type should move relative to the camera.`
`   Not compatible with splitscreen.`
`   Should not normally be used in combination with clipping/bouncing.`

### perframe {#perframe}

`   apply inverse frametime to count (causes emits to be per frame).`

### averageout {#averageout}

`   average trail points from start to end, useful with t_lightning, etc`

### nostate {#nostate}

`   Causes the particle system to ignore all state information.`

### nospreadfirst {#nospreadfirst}

`   don't randomize org/vel for first generated particle`

### nospreadlast {#nospreadlast}

`   don't randomize org/vel for last generated particle`

### sound <soundname> <vol> <attenuation> \[pitch\] \[delay\] {#sound_pitch_delay}

`   When the effect is first spawned, the named sound will play with the given volume and attenuation at the center point. This may not work with all spawn methods, as it will ignore any count scales.`

### lightradius <radius> {#lightradius}

`   Spawns a dlight when the effect is spawned.`
`   dlight is removed when radius drops to 0 or the age is exceeded.`
`   at this time it is not possible to override the corona/specular levels.`

### lightradiusfade <radiuspersecond> {#lightradiusfade}

`   how fast the light radius shrinks per second`

### lightrgb <r> <g> <b> {#lightrgb}

`   dlight rgb colours. 1=white. higher values can over-saturate.`

### lightrgbfade <r/s> <g/s> <b/s> {#lightrgbfade}

`   how fast lightrgb changes over time.`

### lighttime <maxage> {#lighttime}

`   Specifies the maximum lifetime of your dlight.`

### lightcubemap <cubemapnum> {#lightcubemap}

`   value 0 means no cubemap.`
`   otherwise with eg cubemap 5, uses image files cubemaps/5ft.tga, cubemaps/5bk.tga, etc.`
`   fixme: at the current time, the cubemap is world-aligned and cannot rotate.`

lightscales <ambient> <diffuse> <specular>

`   multipliers for the rtlight's various types of lighting`

### lightshadows <castshadows> {#lightshadows}

`   0 or 1, specifies whether the rtlight will cast shadows or not. Its faster if it doesn't.`

### lightcorona <intensity> <scale> {#lightcorona}

### model <name> \[options\] {#model_options}

`   options are:`
`       frame=`
`       framestart=`
`       framecount=`
`       frameend=`
`       frames=`
`       framerate=`
`       skin=`
`       alpha=`
`       scalemin=`
`       scalemax=`
`       trail=`
`       orient`
`       additive`
`       transparent`
`       fullbright`
`       shadow`
`       noshadow`
`   spawns sprites or models that fly away with random angles and run through some frame sequence. handy for simple gib effects.`

### sound <name> \[options\] {#sound_options}

`   options are:`
`       vol=`
`       attn=`
`       pitch=`
`       delay=`
`       weight=`
`   Plays a sound when the effect is spawned. Only ONE sound will be used, picked randomly from the included sounds according to their weights.`

### spawnstain <radius> <r> <g> <b> {#spawnstain}

`   Controls whether a stain will be created at the same time as any particles (instead of depending upon impacts).`

### rainfrequency <multiplier> {#rainfrequency}

`   Specifies the interval between spawning new particle puffs on surfaces.`

### flurry <magnitude> {#flurry}

`   These particles will periodically all change their direction, in a vauge attempt to approximate snow flurries.`

## Cvars {#cvars}

-   [r_particledescr](/Cvar:_r_particledescr "wikilink")
-   [r_particlesystem](/Cvar:_r_particlesystem "wikilink")