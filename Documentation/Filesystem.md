# Filesystem

## Launching

The `nuclide` shell script is the launcher.

It sets **$PATH** to include the directory `bin/` which contains the engine that
you've built with `build_engine.sh`.

When nuclide is run and executes the engine, it'll first read `default.fmf` which
is a manifest file the engine reads. It is updated occasionally.

It defines which directories to mount in the virtual filesystem of the engine
and has a document entirely dedicated to itself. For that please read:

```
	src/engine/specs/fte_manifests.txt
```

## Loading Games

On its own, Nuclide launches the game directory `base/`, unless you tell it otherwise:

```
./nuclide -game mygame
```

Will load `mygame/` instead of `base/`.

You can also load multiple additional directories in a specific order by specifying
multiple `-game` command-line arguments.

It will still load the other `BASEGAME` entries listed in the default.fmf.
You can even load your own manifest file over default.fmf, by passing

```
	./nuclide -manifest mymanifest.fmf
```

## Virtual-Filesystem

When a game is mounted, we're either looking for **loose files** (loaded last), or
**archives** the engine supports.

The Quake .pak archive format, or zip archives with the pk3 and pk4 extensions are supported.
Upon initializing the filesystem they are enumerated alphabetically and then loaded in order.

Directories with the .pk3dir extensions are treated as if they were .pk3 archives.
The editor also supports .pk3dir directories.

Once the game has loaded a game directory, it'll load the persistent menu.dat into our QuakeC
virtual machine.

It' always running, you can make your own by modifying `src/menu-fn/`, `src/menu-vgui/`
or writing your own module.

## Archives

Protected archives always start have the prefix **pak**[...] and cannot be downloaded by connecting
to a server that has them.
**Use this for any copyrighted data.**

When you spawn a map, you create a server which will distribute its own client-side game-logic.

It's advised that you do not pack **csprogs.dat** and **progs.dat** into a protected archive.


## Nuclide specific formats

Nuclide contains many custom definition files that are not engine specific.
`.efx`, `.font`, `.sndshd` and `.way` to name a few.
The game-logic mostly handles them and can thus be, in theory, extended by you.