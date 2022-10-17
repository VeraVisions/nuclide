# Models: VVM
**Vera Visions Model**, also known as **VVM** or **IQM-FTE** is the main
skeletal model format.

## Features {#features}

Features that the original IQM exporter (by Lee Salzman) did not offer:

-   Support for external configuration files for IQM generation (ala
    studiomdl)
-   Pre-processor for rotating single or all input files
-   Pre-processor for translating/repositioning single or all input
    files
-   Pre-processor for renaming bones inside a single or all input files
-   Pre-processor for material prefixes inside a single or all input
    files

Some features that our extended specification (VVM) has to offer:

-   Support for hitmeshes for faster, content-aware collision detection
-   Automatic hitmesh generation
-   Submodels that allow showing/hiding specific groups of the model via
    the game-logic
-   Support for frame triggered events that can be read by the
    game-logic (model-events)
-   Level-of-detail range flag for references/sub-models
-   User-defined surface and contentflags per reference/sub-model

**NOTE: Using any of the VVM features is not supported in any engine
other than FTEQW**

The tool's output will let you know if you're outputting an IQM
compatible file or not.

It also has a re-engineered exporter that takes control files as input,
rather than a giant command-line string. This was done because some
models have hundreds of model parameters in The Wastes.

## History {#history}

In 2016 when we had our first prototype of The Wastes, we started out
using DPM for tool-chain related reasons and quickly migrated to IQM.
However we needed a better system for handling reproducible output
files. The original tool only handled compilation via plain command-line
parameters which was not good enough.

The input command file (.qc) syntax is obviously inspired by qdata and
other tools such as studiomdl. So if you're familiar with those tools
you know exactly what to expect.

We then went on and designed extensions that we needed to make the game
work, for example a generic model-events system that'd call events in
the game-logic when a certain key-frame in the model is displayed.

More complicated things were hit-meshes, for more accurate hit detection
of body parts as well as sub-models that made the action of shooting
body-parts off possible.

We developed this together with David of FTEQW, since this had to be
developed in conjunction with the FTEQW built-ins that'd later be
exposed to the game-logic.

However, the initial extensions to the IQM format in FTE were designed
by us; and this is the exporter that was used to make our game.

## Viewing VVM Models {#viewing_vvm_models}

You can grab a binary build of FTE [1](https://www.fteqw.org/)
(basically a generic, non The Wastes specific version) and use the
'modelviewer' command in the console. The console can be opened via
Shift+ESC.

If you want to see for example the Winston viewmodel, type *modelviewer
models/weapons/v_winchester.vvm*

## External links {#external_links}

[vvmtool on GitHub](https://github.com/VeraVisions/vvmtool)