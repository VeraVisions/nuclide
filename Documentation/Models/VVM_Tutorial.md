# Models: VVM Tutorial
## Introduction {#introduction}

As you already know, the VVM exporter (vvmtool) takes inspiration from
Valve's **studiomdl** in terms of usage. There are *slight* syntax
differences, primarily because the way some features are implemented
differ **drastically**.

For example, **model events** can be stacked and applied to many
animation sequences at once. *There is no way to do so with studiomdl.*

## Input files {#input_files}

Any .vvm consists of multiple input files. These can come in the
following formats:

-   SMD (GoldSrc & Source)
-   MD5MESH and MD5ANIM (idTech 4)
-   FBX
-   IQE
-   OBJ (no animations)

Make sure that when you use animated files, that the bone naming and
bone order is consistent among them.

## Control File {#control_file}

This file is the head of the format. It specifies how the input files
are loaded in, with additional useful commands on how to manipulate the
input data. Many of these features would **not be possible** with an
internal, modeling program specific exporter for VVM.

Here's an EXCERPT of a control file from **The Wastes*:

```
    output tommygun.vvm
    materialprefix models/weapons/tommygun/

    bone "Bone55" rename "Muzzleflash"

    scene ref/tommygun.smd
    rotate 0 -90 0

    scene seq/idle.smd fps 20.0
    scene seq/idle_empty.smd fps 20.0

    event 0 1004 "weapons/tommygun/draw.wav 1"
        scene seq/draw.smd fps 25.0

    event reset
    event 0 1004 "weapons/tommygun/draw.wav 1"
        scene seq/draw_empty.smd fps 25.0

    event reset
    event 0 1004 "weapons/tommygun/holster.wav 1"
        scene seq/holster.smd fps 30.0

    event reset
    event 0 1004 "weapons/tommygun/holster.wav 1"
        scene seq/holster_empty.smd fps 30.0

    origin 0 -32 0

    event reset
    event 14 1004 "weapons/tommygun/clipout.wav 1"
    event 48 1004 "weapons/tommygun/clipin.wav 1"
        scene seq/reload_not_empty.smd fps 22.0
    event 64 1004 "weapons/tommygun/bolt.wav 1"
        scene seq/reload.smd fps 22.0

    origin 0 0 0

    event reset
    event 0 1001 "33 models/effects/muzzleflash/muzzleflash2.vvm"
    event 0 1002 "3 40 0 70"
    event 0 1005 "33 1"
        scene seq/shoot.smd fps 30.0
        scene seq/shoot_last.smd fps 30.0
```

That's a really complicated control file, but it highlights a few
things:

-   You can specify as many events as you like...
-   and apply them to as many scenes as you want.
-   Creating an interface for a dedicated, in-modeling-program exporter
    would be unfeasible.
-   You can run commands to fix existing model input files after the
    fact, like bone renaming...
-   ... and even rotation, scaling and origin re-adjusting (on a
    per-input-file basis!)
-   The **origin** command is absolute, so set it to '0 0 0' to reset

However, a model control file doesn't need to be this complicated:

```
        output terminal01.vvm
        materialprefix models/props/computers/
        rotate 0 -90 0
        scene ref/terminal01.smd
```

This is `models/props/computers/terminal01.qc` from The Wastes.

What each line means:

`output` specifies the resulting final output file name and location
relative to the control file.

`materialprefix` just appends this string to any referenced material.
Ideally it's the location where the .vvm itself is stored in your game
filesystem.

`rotate` Simply rotates all input files by 90 degrees on the Y/Yaw axis
upon importing.

`scene` Tells it to load one input file, which is a reference. If it was
an animation it'd specify a framerate via the 'fps X' parameter.

## Compiling {#compiling}

You grab your copy of **vvmtool** and you either drag
and drop your control file onto it, or run it via command-line:

`vvmtool.exe foobar.qc`

It should be as simple as that!

## Notes {#notes}

Some helpful tips for your content creation journey.

### vid_reload {#vid_reload}

I recommend getting a single reference, plus the animations into your
game first, then adding events and other necessary commands on top.

You can use the console command `vid_reload` to force the engine to
flush the model/texture cache and to reload an updated model from disk.
Really useful when iterating over model exports.

### Blender users {#blender_users}

If you're using the Blender Source Model tools, as of 2021, it still
doesn't down-mix certain animation features into the .smd format.

**This is a problem with the Blender exporter, not vvmtool (as it also
won't work in studiomdl).**

So if your bones seem completely messed up, try .fbx instead.

If you absolutely need to use .smd, export it as .fbx in Blender, import
said output back into Blender and then export as .fbx.