# Particles {#particles}

**Particles**, part of a *particle system*, are sprites/models in 3D space
that simulate impacts and other chemical reactions. They can be used for
a variety of use cases - most commonly they're used for explosions,
bullet impacts and smoke.

In Nuclide we are happy to use the built-in engine particle system.

The particle system in **FTEQW** is quite advanced despite its
use of a plaintext scripting format.

By default, particle definitions are read from either the game/mod its
`default.cfg` file, or from `<gamedir>/particles/default.cfg`.

The path can be changed by overriding the console variable `r_particledescr`.
The scripted particle system is also only available when `r_particlesystem`
is left to the default value of `script`.

## Syntax {#particles_syntax}

Particles are similar to [Materials](@ref materials) in the way
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

For inspiration or help in experimentation, it's best to look at particle configs
in existing games.

## Commands {#particles_commands}

### Types {#particle_types}
Always try to include a type. The engine will guess what your
particle is meant to be otherwise, based on textures and other factors.

### Chaining {#particle_chains}
You can add multiple particle descriptions to a single effect.
The first should be `r_part foo`, and the others should be `r_part
+foo`. Particles without a + will reset the chain.

### Naming {#particle_naming}
Effects set by `r_particledesc` will be given an internal prefix,  
eg: `foo.cfg`. 

If the gamecode or entityDef explicitly states `foo.bar`, your `foo.cfg` will   
automatically be executed, and will automatically use the `bar` effect from it.  
The effect can still be overriden from a custom config by *explicitly* naming  
the effect `foo.bar` - the effect `bar` in the config `foo` will not override  
this, but would override `bar` on its own.

## Scale {#particle_scale}
Such values are defined in 1/4th qu, for some reason.
The value of `scalefactor` typically needs to be explicitly set to `1`.
This value affects how the particle scales with distance from view, rather than  
the actual size of the particle.

### texture <TEXTURENAME> {#texture}

Specifies to use an image named `<TEXTURENAME>` for this effect.

For example: `texture "gfx/particles/explosion.tga"`

### shader <materialname> \[{ matbody }\] {#shader_materialname_matbody}

Specifies to use a named material, instead of a texture sample.
The name is a misnomer, it does not affect a programmable shader to use,  
but a 'Q3A Shader' which are now just referred to as Materials.

If `matbody` is included (as a nested block on the following line) then  
that material text will be used to create the material if it doesn't  
otherwise exist in memory.

This overrides blend modes specified using the @ref blend command.

### tcoords <s1> <t1> <s2> <t2> \[tscale\] \[rsmax\] \[rsstep\] {#tcoords_tscale_rsmax_rsstep}

Specifies to use a subsection of the image.

If `tscale` is set, all units are divided by this. it is the virtual size  
of your texture.  
So a value of `1` means that your texture coords must be between `0` and `1`.  
But if it properly matches your texture's size, the coords are in pixels.

If `rsmax` is present, each particle will use a random image.  
These images must be on a single row in your particle font.  
The `rsstep` value specifies the stride (gap from one to the next) in your  
particle font, and is only needed if `rsmax` is present and greater than `1`.

### atlas count_in_each_axis firstidx \[last\] {#atlas_count_in_each_axis_firstidx_last}

An alternative to tcoords.

The specified texture (or shader) is to be considered as a grid of sprites (x times x, where x is specified by `count_in_each_axis`).  

Value of `firstidx` specifies the first image to use (horizontal, then vertical).  

Value of `last` specifies the last image to use (inclusive).  

The engine will pick one at random. They should not span multiple rows.

### rotation <startmin> <startmax> <speedmin> <speedmax> {#rotation}

The particle will start with a rotation rotated between `startmin` and `startmax`.
It will then rotate with some per-particle value randomly picked  
between the `speedmin`+`speedmax` values.

@important Should not be used on `type beam` particles.

### beamtexstep <value> {#beamtexstep}

Specifies the number of game units per beam texture repetition.

### beamtexspeed <value> {#beamtexspeed}

Controls how fast the texture scrolls on the beam.

@note Only valid if the effect is a `type beam`.

### scale <min> \[max\] {#scale_max}

Particles will start with a diameter of this many game units.

Actual scale will be randomly chosen between `min` and `max`.
The `max` defaults to equal if `min` is missing.

### scalefactor <frac> {#scalefactor}

Controls how the particle scales with distance.
Value of `1` makes the particle scale the same as anything else.
Value of `0` makes the particle not change size no matter how far it is.

### stretchfactor <factor> {#stretchfactor}

Controls how spark particles stretch according to their velocity.
Negative values give fixed length sparks.

### scaledelta <value> {#scaledelta}

Controls how the particle scales over time.
Specifies the change in the particle scale per second.

@note Due to technical reasons, any `type decal` particles are unable to use this parameter.

### step <min> <max> {#step}

Specifies the distance between each particle in the trail (or beam).

@note Trails/beams only.

### count <min> <max> {#count}

Specifies how many particles are spawned per effect.  
Some classic effects contain an extra scaler which is multiplied by the resulting value.

@note Point/box effects only (not trails or beams).

### alpha <value> {#alpha}

Specifies the initial alpha value of the effect.

### alpharand <value> {#alpharand}

Specifies a randomized additonal value added to each particle's initial alpha.

### alphadelta <value> {#alphadelta}

Specifies how much the alpha value of the effect changes per second (subtracted).

### die <maximum age> <minimum age> {#die}

Specifies the maximum age of the particle. In seconds.

### randomvel <horiz> \[vert\] {#randomvel_vert}

Controls how fast the particle moves when it spawns (according to its spawn pattern).  
This works regardless of any requested velocities.

If `vert` is not specified, `horiz` is used instead.

### veladd <value> {#veladd}

Controls how much of the effect's spawn velocity is used, can be greater than `1`, or negative.

### orgadd <value> {#orgadd}

Biases how much to add to the starting origin relative to the requested velocity.

### orgbias <x> <y> <z> {#orgbias}

Biases the particle's origin by this absolute worldspace vector, regardless of spawn mode.

### velbias <x> <y> <z> {#velbias}

Biases the particle's velocity by this absolute worldspace vector, regardless of spawn mode.

### orgwrand <x> <y> <z> {#orgwrand}

Randomised offset for the particle's origin, in worldspace.

### velwrand <x> <y> <z> {#velwrand}

Randomised offset for the particle's origin, in worldspace.

### friction <xyz> {#friction_1}
### friction <xy> <z> {#friction_2}
### friction <x> <y> <z> {#friction_3}

Proportion of the particle's speed that should be lost from friction. Negative values are accepted.

### gravity <value> {#gravity}

Amount that the particle's velocity changes per second, in game units.

### clipbounce <value> {#clipbounce}

How much of the particle's velocity to use if the particle is clipped. See @ref cliptype.
Defaults to `0.8`.

### cliptype <effectname> {#cliptype}

Specifies which new effect to spawn when the particle hits something.  

The origin and velocity of the particle are used to spawn the new effect.

The @ref clipbounce value is used as a scaler for the reflected velocity.

If the effect named is the effect itself, the particle will merely bounce,  
instead of spawning a new effect.

### clipcount <count> {#clipcount}

The scaler to use for the number of particles to spawn upon a clip event.
Only valid in conjunction with cliptype.

### assoc <effectname> {#assoc}

Specifies another effect to spawn at the same time that this effect is spawned.
Thus allowing two sets of particles from one effect.

### notunderwater \[content names\] {#notunderwater_content_names}

Specifies that this particle should only be spawned when out of water.

The particle will not spawn under water (this does not affect [assoc chains](@ref particle_chains)).  
Content names are a space-separated list of: `water slime lava sky solid fluid`.  
Default is `fluid` if not specified.  

The `r_part_contentswitch` cvar must be enabled for this to function correctly.

### underwater \[content names\] {#underwater_content_names}

Specifies that this particle should only be spawned when underwater.
The inverse of @ref notunderwater_content_names.

### citracer {#citracer}

Adds a palette index between `0` and `3`, based on the particle index in the effect or trail.

@note Only valid if `colorindex` is set.

### red <value> {#red}

### green <value> {#green}

### blue <value> {#blue}

### rgb <red> <green> <blue> {#rgb}

### rgb <value> {#rgb_1}

### rgbf <red> <green> <blue> {#rgbf}

Specifies the initial red, green, and/or blue values for each particle.
Fully opaque is `255` or above.
Values above `255` are valid, but will remain opaque until the value drops below 255 from the color deltas.
The @ref rgbf form takes values scaled by `1` instead of `255`.

### redrand <value> {#redrand}

### greenrand <value> {#greenrand}

### bluerand <value> {#bluerand}

### rgbrand <red> <green> <blue> {#rgbrand}

### rgbrand <value> {#rgbrand_1}

### rgbrandf <red> <green> <blue> {#rgbrandf}

Specifies how much extra red, green, and/or blue there may be for particles.
The initial color will be multiplied by this amount before addition.
Each componant is separately randomized. EG, red might  add nothing, while the full green is added, and only half the blue.
Fully opaque is `255` or above.
The @ref rgbrandf form takes values scaled by `1` instead of `255`.

### redrandsync <value> {#redrandsync}

### greenrandsync <value> {#greenrandsync}

### bluerandsync <value> {#bluerandsync}

### rgbrandsync <red> <green> <blue> {#rgbrandsync}

### rgbrandsync <value> {#rgbrandsync_1}

Specifies how much extra red, green, and/or blue there may be for particles.
The initial color will be multiplied by this amount before addition.
Componants are syncronised. EG, if the full amount of red is added, the full amount of green and blue will also be added.
Fully opaque is `255` or above.

### reddelta <value> {#reddelta}

### greendelta <value> {#greendelta}

### bluedelta <value> {#bluedelta}

### rgbdelta <red> <green> <blue> {#rgbdelta}

### rgbdelta <value> {#rgbdelta_1}

### rgbdeltaf <red> <green> <blue> {#rgbdeltaf}

Specifies how much the red, green, and/or blue values of each particle change over time.
The value `255` is the value required to go from opaque to invisible in `1` second.

### rgbdeltatime <value> {#rgbdeltatime}

Specifies for how long the particle may change colors for.  
After this many seconds, the particle may no longer change colors (delta becomes 0).

### rampmode <mode> {#rampmode}

Mode may be one of:
- none: uses rgb+rand+sync+delta+scale+scaledelta values.
- nearest(or absolute): the ramp overrides all color+scale values.  
  The effect moves from one absolute ramp index to the next.
- lerp: smoothly interpolates from one value to the next.
- delta: uses rgb+rand+sync+scale, but not delta values.  
  All delta values come from the color ramp instead.

if not none, the ramp index used is based upon the particle's age, its lifetime,  
and how many ramp elements there are.

### rampindexlist <idx1> \[<idx2> \[idx3 ...\]\] {#rampindexlist_idx3_...}

Scale used is the currently set scale value.
Specifies a set of palette index values to use for the effect as part  
of the effect's color ramp.

### rampindex <idx> <scale> {#rampindex}

Specifies an individual palette index value and particle scale to use  
for the effect as part of the effect's color ramp

### ramp <red> <green> <blue> \[alpha\] \[scale\] {#ramp_alpha_scale}

Specifies a ramp index in rgb terms, regardless of palette.

### stains <value> {#stains}

How much the effect discolors the wall upon impact.
The stained color is based upon the color of the particle upon impact.

### blend <mode> {#blend}

If the texture used is actually a material then its blend mode  
will take precedence.  

@note As a general rule you should try to use only the premul blend modes, as well as atlasing to regain some performance.  

The `mode` value may be one of the following:

- `blend` - Blend based on alpha channel. Default.
- `blendalpha` - Blend using alpha. Same as `blend`.
- `blendcolor` - Blend using colors. If a pixel in the particle texture is black, then the background is fully visible. Equivalent to OpenGL blend mode `GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR`.
- `add` - Additive blend using alpha. Equivalent to OpenGL blend mode `GL_SRC_ALPHA, GL_ONE`.
- `adda` - Same as `add`.
- `addc` - Additive blend using color. Equivalent to OpenGL blend mode `GL_SRC_COLOR, GL_ONE`.
- `subtract` - Subtract color from background, using particle texture's alpha.
- `invmoda` - Inverted `add` and `adda`. Equivalent to OpenGL blend mode `GL_ZERO, GL_ONE_MINUS_SRC_ALPHA`.
- `invmodc` - Inverted `addc`. Equivalent to OpenGL blend mode `GL_ZERO, GL_ONE_MINUS_SRC_COLOR`.
- `premul_blend` - Like `blend`  but pre-multiplied.
- `premul_subtract` - Like `subtract` but pre-multiplied.
- `premul_add` - Like `add` but pre-multiplied.
- `rtsmoke` - Blended and lit with realtime lighting, instead of being unlit. 

### spawnmode <mode> \[arg1\] \[arg2\] {#spawnmode_arg1_arg2}

This affects how particles are positioned when they first spawn, and their initial velocities.

For point-based effects, mode may be one of:

- circle: particles spawn within a ball with uniform distance from the center. none will appear in the middle.  
           arg1: percentage of the circle to cover. a value of 5 will go around the circle 5 separate times. this can be used for weird beam effects.  
           areaspread: the radius of the ball  
           areaspreadvert: the height of the ball. if 0, will be a flat circle  
- ball: particles spawn randomly within a ball.  
           areaspread: the radius of the ball  
           areaspreadvert: the height of the ball. if 0, will be a flat circle.  
- telebox: Matches Quake's telebox.
- lavasplash: Like Chthon's lava splash in Quake.  
- uniformcircle: Particles are spawned in a circle with uniform distance between and from the center. z=0.  
- syncfield: Particles spawn at predictable locations based upon time within a rough sphere. Only useful for effects that are regenerated+replaced every frame.  
- distball: Some ball.  
- box: Simple, axially aligned box of particles. The Default.

For trail-based effects, mode may be one of:

- spiral: particles are given velocities perpendicular to the direction based on the distance moved.
- tracer: particles spawn with alternating horizontal velocities (a wake effect).
- default: particles spawn as a regular trail.

### type <mode> {#type}

Sets how the particles look.

Options for modes are:

- beam: Valid only for trails. Particles form a single textured beam
    acting as nodes along it.
- vbeam: Same as beam.
- spark: particles are lines, their length depending upon their speed.
- linespark: Same as spark.
- sparkfan: particles are non-planar triangle fans, their length
    depending upon their speed.
- trianglefan: Same as sparkfan.
- texturedspark: textured particles are aligned along their direction
    of movement, their length depending upon their speed, width equal to
    their scale.
- decal/cdecal: particles are spawned only upon bsp geometry. They are
    clipped by it.
- udecal: unclipped decal. exact semantics are subject to change.
- normal: Particles are regular, rotating, 2d images. The Default.

### clippeddecal <mask> \[match\] {#clippeddecal_match}

@note Implies 'type decal'.

The two extra args allow you to spawn these decals ONLY on surfaces with matching surfaceflags.

Separation of mask+match allows you to create many descrete surface types instead of being limited to 32 bits/types.

### spawntime <value> {#spawntime}

### spawnchance <value> {#spawnchance}

### emit <effectname> {#emit}

Specifies the effect to periodically emit.

### emitinterval <min> {#emitinterval}

Particles will not emit additional effects for this duration after emitting one.

### emitintervalrand <extra> {#emitintervalrand}

Adds an amount of randomness to the emit interval.

### emitstart <seconds> {#emitstart}

Prevents the particle from emitting anything for this duration when it first spawns.

### viewspace \[frac\] {#viewspace_frac}

Specifies that this particle type should move relative to the camera.

@important Should not normally be used in combination with clipping/bouncing.
@note Not compatible with splitscreen.

### perframe {#perframe}

Apply inverse frametime to count (causes emits to be per frame).

### averageout {#averageout}

Average trail points from start to end, useful with effects like `t_lightning`, etc

### nostate {#nostate}

Causes the particle system to ignore all state information.

### nospreadfirst {#nospreadfirst}

Don't randomize org/vel for first generated particle.

### nospreadlast {#nospreadlast}

Don't randomize org/vel for last generated particle.

### sound <soundname> <vol> <attenuation> \[pitch\] \[delay\] {#sound_pitch_delay}

When the effect is first spawned, the named sound will play with the given volume  
and attenuation at the center point.  
This may not work with all spawn methods, as it will ignore any count scales.

### lightradius <radius> {#lightradius}

Spawns a dlight when the effect is spawned.
Dlight is removed when radius drops to 0 or the age is exceeded.

### lightradiusfade <radiuspersecond> {#lightradiusfade}

How fast the light radius shrinks per second.

### lightrgb <r> <g> <b> {#lightrgb}

Dynamic light colors. The value of `1` equals white.
Higher values can over-saturate.

### lightrgbfade <r/s> <g/s> <b/s> {#lightrgbfade}

How fast @ref lightrgb changes over time.

### lighttime <maxage> {#lighttime}

Specifies the maximum lifetime of your dlight.

### lightcubemap <cubemapnum> {#lightcubemap}

Set to `0` for no cubemap.
Otherwise with e.g. `cubemap 5`, uses image files `cubemaps/5ft.tga`, `cubemaps/5bk.tga`, etc.

### lightscales <ambient> <diffuse> <specular>

multipliers for the rtlight's various types of lighting.

### lightshadows <castshadows> {#lightshadows}

Can be `0` or `1`, specifies whether the dynamic light will cast shadows or not.
It's faster if it doesn't. So the default is `0`.

### lightcorona <intensity> <scale> {#lightcorona}

Gives the light being cast a corona at the specified intensity and size, in game units.

### model <name> \[options\] {#model_options}

Spawns sprites or models that fly away with random angles and run through some frame sequence.
Handy for simple gib effects.

```
   options are:
       frame=
       framestart=
       framecount=
       frameend=
       frames=
       framerate=
       skin=
       alpha=
       scalemin=
       scalemax=
       trail=
       orient
       additive
       transparent
       fullbright
       shadow
       noshadow
```

### sound <name> \[options\] {#sound_options}

Plays a sound when the effect is spawned. Only one sound will be used, picked randomly from the included sounds according to their weights.

options are:  

```
       vol=
       attn=
       pitch=
       delay=
       weight=
```

### spawnstain <radius> <r> <g> <b> {#spawnstain}

Controls whether a stain will be created at the same time as any particles,  
instead of depending upon impacts.

### rainfrequency <multiplier> {#rainfrequency}

Specifies the interval between spawning new particle puffs on surfaces.

### flurry <magnitude> {#flurry}

These particles will periodically all change their direction, in a  
vauge attempt to approximate snow flurries.

## Console Commands

### listParticles

Will ask Nuclide to list all currently precached particle effects.
