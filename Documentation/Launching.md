# Launching {#launching}

If you [built a custom branded version of the engine](@ref build-engine), you can run that as is.

Using a generic [FTE](https://www.fteqw.org/) binary however, you need to specify the game directory.
You run `./fteqw` with a parameter specifying the game directory:

```
$ ./fteqw +game base
```

You can dispatch [console](@ref console) commands to be executed once the client is running by appending them to the command-line as launch parameters, prefixed with the `+` character, as seen above.

```
./TestGame_x64 +set g_gametype some_mode +devmap some_level
```

## Mod/Game Setup

For mods to show up in the "Custom Game" menu, Nuclide has to either find a `liblist.gam` file, a [FTE-specific](https://www.fteqw.org/) manifest
file, or , or a [Source Engine](https://web.archive.org/web/20110724220714/http://source.valvesoftware.com/) styled `GameInfo.txt` inside the respective mod directory.

It'll scan [resource archives](@ref archives), as well as loose files in the mod directory,
however it will *not search inside any sub-directories*.

A liblist.gam file can look something like this:

```
  game "My Cool Mod"
  version "1.0"
  startmap "e1m1"
  trainingmap "traininglevel"
```

You can find the types of key/value pairs a game can use to identify itself in GameLibrary_LibListParse()
under `src/platform/gamelibrary.qc`.

Those settings alone can alter quite a bit of the menu options and branding/presentation of your game.
