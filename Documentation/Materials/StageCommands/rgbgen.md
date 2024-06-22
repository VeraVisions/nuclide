# Material Command List {#mat_commands}

### rgbGen {#rgbGen}

#### Syntax

**rgbGen <func>**

**rgbGen wave <func> <base> <amp><phase> <freq>**

#### Overview

Defines what vertex colors are set to for any given surface.

If no rgbGen is specified, either "identityLighting" or"identity" will
be selected, depending on which blend modes are used.

Valid <func> parameters are const, wave, identity, identityLighting,
entity, oneMinusEntity, fromVertex, and lightingDiffuse.

#### Functions

##### const

Follow this up with a vector of the color that you'd like the vertex
colors to be set as. An example for green would be:
```
  rgbGen const 0.0 1.0 0.0
```

##### identityLighting

Colors will be (1.0,1.0,1.0) if running without overbright bits (NT,
linux, windowed modes), or (0.5, 0.5, 0.5) if running with overbright.
Overbright allows a greater color range at the expense of a loss of
precision. Additive and blended stages will get this by default.

##### identity

Colors are assumed to be all white (1.0,1.0,1.0). All filters stages
(lightmaps, etc) will get this by default.

##### entity

Colors are grabbed from the entity's .colormod field.

##### oneMinusEntity

Colors are grabbed from 1.0 minus the entity's .colormod field.

##### entityLighting

Introduced by [FTE](FTE), same as entity, but will receive
lighting similar to identityLighting on top of it.

##### vertex

Colors are filled in directly by the data from the map or model files.
This is used for blending brushes and patches. It was used at one point
to store primitive lighting, in case the lightmapped rendering path was
to expensive (this is no longer available).

##### oneMinusVertex

As rgbGen vertex, but inverted.

Design Note: This keyword would probably not be used by a level designer

##### lightingDiffuse

Colors are computed using a standard diffuse lighting equation. It uses
the vertex normals to illuminate the object correctly.

Design Note: -rgbGen lightingDiffuse is used when you want the RGB
values to be computed for a dynamic model (i.e. non-map object) in the
world using regular in-game lighting. For example, you would specify on
materials for items, characters, weapons, etc.

##### wave <func> <base> <amp><phase> <freq>

Colors are generated using the specified waveform. An affected texture
with become darker and lighter, but will not change hue. Hue stays
constant. Note that the rgb values for color will not go below 0 (black)
or above 1 (white). Valid waveforms are **sin**, **triangle**,
**square**, **sawtooth** and **inversesawtooth**.

###### <func>

-   **Sin**: color flows smoothly through changes.
-   **Triangle**: color changes at a constant rate and spends no
    appreciable time at peaks and valleys.
-   **Square**: color alternates instantly between its peak and valley
    values.
-   **Sawtooth**: With a positive frequency value, the color changes at
    a constant rate to the peak then instantly drops to its valley
    value.
-   **Inversesawtooth**: An inverse sawtooth wave will reverse this,
    making the ascent immediate (like a square wave) and the decay fall
    off like a triangle wave.

###### <base>

Baseline value. The initial RGB formula of a color (normalized).

###### <amp>

Amplitude. This is the degree of change from the baseline value. In some
cases you will want values outside the 0.0 to 1.0 range, but it will
induce clamping (holding at the maximum or minimum value for a time
period) instead of continuous change.

###### <phase>

See the explanation for phase under the waveforms heading of Key
Concepts.

###### <freq>

Frequency. This is a value (NOT normalized) that indicates peaks per
second.
