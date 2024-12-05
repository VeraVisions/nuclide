# Building {#building}

## Preface

If you don't plan on modifying the engine, then you can grab binaries
from [FTE's website](https://www.fteqw.org) and move the binaries for your platform into the root
directory of Nuclide.

## Dependencies

![](application_osx_terminal.png) Nuclide is entirely game-logic oriented, so it only requires a working
QuakeC compiler. In our case [FTEQCC](https://www.fteqcc.org/). Which
you can also build with:

```
$ make fteqcc
```

The resulting binary `./fteqcc` will then be used to build the
game-logic related targets.

Besides a working **C** compiler, such as `gcc` or `clang`, the QuakeC compiler shouldn't need any other dependencies. [Click here for a full list of dependencies for the various optional components.](Documentation/Dependencies.md)

@note `make help` will always show a list of available targets, including their purpose.

## Keeping Up-To-Date

You can issue the following to check for updates of tools/dependencies:

```
$ make update
```

## Building Game-Logic {#build-game}

You can build games by running the following command:

```
$ make game GAME=base
```

Adjust the **GAME** argument to select which game you want to
build. The game `base` is the assumed, default target.

Usually, the resulting files are `progs.dat`, `csprogs.dat` and
(sometimes) `menu.dat`. Those are the libraries dealing with the
**Server**, **Client** and **Menu** aspect of the game respectively.

They are accompanied by name-matching `.lno` files. These contain
extra debugging information helpful to the engine. *They can be
stripped from a shipping build of your game.*

@note You do not need to rebuild the logic for each and every platform. The results will be identical, since QuakeC is not machine code!

## Building the Engine {#build-engine}

Issue the following to build a generic, non-branded version of the engine [FTE](https://www.fteqw.org/):

```
$ make fteqw
```

Which you can then use to run 'Test Game' with `./fteqw +game base`. [For more information on launching games, mods, check out the page on Launching](Documentation/Launching.md).

@note Some engine features are only available as a plugin. See the section on plugins for details.

### Building a Branded Build {#build-branded}

If you want to build a custom version of the engine,
with custom branding and the ability to strip unneeded
functionality out of the binary, you can make a copy of
`ThirdParty/fteqw/engine/common/config_fteqw.h`, adjust it and save
it under your game directory as `engine.h`. When issuing the command:

```
$ make engine GAME=yourgame
```

It will then look for `yourgame/engine.h`, and build a copy of FTEQW
against it.  The output will normally be something along the lines of
`yourgame_x64`.

@note The name can be changed by passing **NAME=YourGame** to the `make` program, or by placing a file named `PROJECT` in your game directory with a short name on the first line.

### Building plugins {#build-plugins}

You can build plugins for your game by specifying **NATIVE_PLUGINS** as an argument to the `make` command, like so:

```
make plugins GAME=base NATIVE_PLUGINS="ode ffmpeg"
```

However, once you've settled on a set of plugins for your game, you can list the contents of the **NATIVE_PLUGINS** string in a file named `PLUGINS` in your game directory.

@note For generic builds of **FTE** you can use the target **fteqw-plugins** instead of **plugins**. You shouldn't specify a **GAME** argument however.

## Building a dedicated server build {#build-dedicated}

![](server.png) If you want a minimal, dedicated server binary for your game that doesn't include all the code related to being a client, you can issue:

```
make dedicated GAME=yourgame
```

And it will, much like a branded build, compile a dedicated binary specific to your game configuration.


## Building the Level Editor {#build-editor}

![](map_edit.png) See [the page dedicated to level editing](@ref radiant) for more information.
