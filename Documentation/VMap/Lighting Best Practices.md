Here we'll run down the practices of lighting your map using
[WorldSpawn](/WorldSpawn "wikilink") and [vmap](/vmap "wikilink").

## Basic Rules {#basic_rules}

-   Point lights are hard to maintain, use surface lights (either
    [vmap_surfaceLight (Material
    Command)](/vmap_surfaceLight_(Material_Command) "wikilink") or
    [light_surface](/light_surface "wikilink"))
-   [light_environment](/light_environment "wikilink") will do a bulk of
    the world lighting, it should even be used in afternoon and dark
    settings
-   Avoid ambient lighting, unless you know exactly what you want, or
    you're in a completely interior-only map

## Global settings {#global_settings}

[light_environment](/light_environment "wikilink") will do the bulk
work. It emits light from any sky surface, such as `common/skyportal`.
The amount of samples specify how many **passes** are done. This will be
~evened~ out to match the desired **intensity**, so increasing samples
does **not** make the map brighter.

Using more than 1 sample is useful if you want less harsh-shadows. Even
a value of 4 with a `sunspreadangle` of e.g. 5-10 degrees is sensible
for day-time maps. It makes them look less artifacting too. The theory
is, the cloudier the world is, the softer the shadows are - so we need
more **samples** and a `sunspreadangle` that's wider to accommodate
that.

The `sunspreadangle` will determine how far apart the different samples
will be spread. E.g. if you set it to '0' it will do nothing. Every
light_environment sample will take place on the exact same spot, from
the same angle. However if you set it to 360 (the maximum amount), each
sample will spread out to get a full 360 coverage of the map. Resulting
in a lightmap without any real contrasting shadows.

## Which light_environment color to use? {#which_light_environment_color_to_use}

99% of the time it's going to be white. Let `_ambient` inside your
light_environment tint the shadows the color of the sky, let radiosity
do its job. Radiosity can't do its job if the sun color is non-white.

**The effects of radiosity will be barely visible using a non-white
light_environment color.**

## Ambient color? {#ambient_color}

Set `_ambient` in your light_environment to whatever the color of the
sky is set to. This determines the color of the shadows cast by the
light_environment. **This does not create a minimum ambient intensity in
the process**

## Minimum light intensity {#minimum_light_intensity}

A really ugly hack, only use it in the worst case scenario.

In your [worldspawn (Entity)](/worldspawn_(Entity) "wikilink") keys, you
can add a `_minlight` intensity value, as well as a `_minlight_color`
value. This is not something you want to use for anything looking good.

It raises the lighting level-wise, but keeps the light values of each
entity/sky/shader intact. A much worse alternative is the worldspawn
`_ambient` key.

**You will never achieve truly black areas in your map after this. Be
warned.**

## What about the worldspawn **_ambient** key? {#what_about_the_worldspawn__ambient_key}

The overall lighting level of the map is raised. This has the tendency
to flatten the difference between light and shadow. The dynamic range is
utterly destroyed.

## What about the worldspawn **_floodlight** key? {#what_about_the_worldspawn__floodlight_key}

With floodlight, light becomes darker in closed spaces and brighter in
wide open spaces.

The worldspawn key for that is `_floodlight`, with you specifying:

` `**<red color>` `<blue color>` `<green color>` `<travel distance>` `<intensity>**

The side effect is that it'll obviously act as a contrasting knob. It
**does not fix spaces where light wasn't present to begin with**!

There are very few artistic use cases for this. However, if your map is
looking very dull/flat, it could help a lot.

## Should I use radiosity? How many bounces? {#should_i_use_radiosity_how_many_bounces}

Half-Life 2 compiled with a maximum of 8 bounces, that is sensible. You
can even set it to 100 and it'll stop once photons lose their energy.

**And of course yes you should use radiosity... Damn it, that fixes most
lighting problems!**

[Category: Level Design](/Category:_Level_Design "wikilink")