# Launching

## For development...
For development, use the `nuclide` launch script inside the root directory.

```
$ ./nuclide
```

Running it on its own will mount the game dir `base/`. As that's the default defined inside the file `./default.fmf`.

You can mount an additional mod over `base/` like so:

```
$ ./nuclide -game some_other_mod
```

If you wanted to mount multiple game dirs, you could in theory do it like so:

```
$ ./nuclide -game first_mod -game second_mod -game third_mod
```

And it'll load those directories in order, on top of `base/`.

However, we advise you only do this for development. If you want proper multiplayer compatibility (slightly different filesystem mount setups can confuse client <> server negotation) please use the built-in **Custom game** menu to ensure maximum compatibility to other clients.

## For release...

You'll want to compile a custom build of the engine with your branding.
Inside `src/engine/engine/common/` you can find a config file named `config_wastes.h`,
which is a good example of how you can customize your engine binaries and filesystem mount-points.

That way you **avoid** shipping a default.fmf file.

**How to compile a custom config build**: You pass `FTE_CONFIG=wastes` to the make environment when building an engine binary - if you wanted to build with the `config_wastes.h` file. [For more information check out the building section](Building.md)

## Mod/Game Setup

For mods to show up in the "Custom Game" menu, we have to either find a manifest
file, or a liblist.gam, or a gameinfo.txt inside the respective mod directory.

It'll scan .pk3 and .pk4 archives, as well as loose files in the mod directory,
however it will not search inside any sub-directories.
It is trying to look inside the dlcache/ folder, but the engine is currently
restricting that.

A liblist.gam file can look something like this:

```
  game "My Cool Mod"
  version "1.0"
  startmap "e1m1"
  trainingmap "traininglevel"
```

But more definitions are available.
Check src/menu-fn/m_customgame.qc's customgame_liblist_parse() function to stay
up to date regarding all the supported liblist variables that can be set.

GameInfo.txt files are supported too. They originate from the Source Engine
filesystem, however there's no concept of Tools and Game AppIDs as Nuclide does
not link against Steamworks.
Support for such definitions is complementary and I'd advise not to expect it
to be feature complete. It has a concept of inheriting multiple paths as defined
by the specification.

If you need more control, you can use manifest files. Similar to the default.fmf
that's in the root Nuclide source tree. You can set liblist entries like this
inside of them:

```
  -set gameinfo_game "My Cool Mod"
  -set gameinfo_version "1.0"
  -set gameinfo_startmap "e1m1"
  -set gameinfo_trainingmap "traininglevel"
```

Please name the manifest the same as the mod/game dir. For example if your game
its directory is named "foobar" name your manifest "foobar.fmf".

That's all there is to know about mod-detection in Nuclide its menu progs.
