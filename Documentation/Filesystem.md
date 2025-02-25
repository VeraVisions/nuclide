# Filesystem

## Virtual Filesystem

The engine binary attempts to initialize a virtual filesystem within a **game directory**. That is a directory in which your entire game lives in. In *id Software* their game **Quake** that directory was named **id1/**, in *Valve* their game **Half-Life** it was **valve/**.

You will be tasked with naming your own game directory, if you were to build your own game.

The example **Nuclide** game, called **Test Game** is stored in **base/**, and is thus often referred to as 'base'.

When a game is mounted, we're either looking for **loose files** (loaded last), or
**archives** the engine supports.

@note You can switch games using the `game` console command.

## Archives {#archives}

![](compress.png) The Quake [pak archive](https://quakewiki.org/wiki/.pak) format, or [zip archives](https://en.wikipedia.org/wiki/ZIP_%28file_format%29) with the **pk3** and **pk4** extensions are supported.
Upon initializing the filesystem they are enumerated alphabetically and then loaded in order, thus the filename affects the load order of archives.

Directories with the .pk3dir extensions are emulated, acting as if they were .pk3 archives. **We recommend you use them to organize your development files.**

### Protected archives

Protected archives always start have the prefix **pak**[...] and **cannot** be downloaded by connecting
to a server game that has them.
**We suggest you use this for any copyrighted data.**


## Game-logic behaviour

When you spawn a map, you create a server (running `progs.dat`) which will distribute its own client-side game-logic (`csprogs.dat`).

But before this, when the client (not the server) has loaded a game directory, it'll load the persistent `menu.dat` into its own QuakeC
virtual machine.

It's always running, unlike `progs.dat` and `csprogs.dat` code which gets reloaded between map changes.
You can use this to your advantage by restarting levels in order to reload game logic, or to reload entity definitions.

In order to restart the menu, you manually issue `menu_restart` via the **engine console** (SHIFT+ESC).

## Restarting the file-system during the game

You can initiate a refresh of the virtual filesystem by issuing `fs_restart` in the **engine console**.

## Reloading assets

You can reload image and/or model assets by issuing `vid_reload` in the **engine console**. While the map geometry may reload, for entity changes you will have to issue a full `map_restart` in the **engine console** to see them reload.
