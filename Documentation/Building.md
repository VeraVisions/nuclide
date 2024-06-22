# Building

## Preface

If you don't plan on modifying the engine, then you can grab binaries
from [FTEQW](https://www.fteqw.org) and move them into the root
directory.

## Dependencies

Nuclide is entirely game-logic oriented, so it only requires a working
QuakeC compiler. In our case [FTEQCC](https://www.fteqcc.org/). Which
you can also build with:

```
$ make fteqcc
```

The resulting binary `./fteqcc` will then be used to build the
game-logic related targets.

Besides a working **C** compiler, such as `gcc` or `clang`, the QuakeC compiler shouldn't need any other dependencies. [Click here for a full list of dependencies for the various optional components.](Documentation/Dependencies.md)

> [!tip]
> `make help` will always show a list of available targets, including their purpose.

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

> [!tip]
> You do not need to rebuild the logic for each and every platform.
> The results will be identical, since QuakeC is not machine code.

## Building the Engine {#build-engine}

Issue the following to build a generic version of the engine [FTEQW](https://www.fteqw.org/):

```
$ make fteqw
```

Which you can then run with `./fteqw -game base`. [For more information on launching games, mods, check out the page on Launching](Documentation/Launching.md).

Some engine features are only available as a plugin. See `$ make help` for info on how to build them.

### Optional: Custom Branding & Features

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
`yourgame_x64`.  The name can be changed by passing `NAME=YourGame`
to the make program.

## Building the Level Editor {#build-editor}

Issue the following to build [GtkRadiant](https://icculus.org/gtkradiant):

```
$ make radiant
```

A launcher will be created in the root directory allowing you to launch it via `./radiant`.

For documentation regarding Radiant and general id Tech level design, [you can visit this page](https://icculus.org/gtkradiant/documentation.html).
