# Modules {#modules}

## AddonC

AddonC is the server side module architecture offered by Nuclide. It is inspired by efforts such as [MetaMod](http://metamod.org/).

### Usage

If the file `<game dir>/plugins.txt` exists, it is loaded into memory. It contains a sorted list of QuakeC progs. The order in which the .dat names are listed, also decides the load order:

```
banner
chatfilter
chatsounds
connectsounds
ircbridge
```

Each entry will result in Nuclide attempting to look for `<gamedir>/Addon_<name>.dat`. So `banner` in the list will resolve to `<gamedir>/Addon_banner.dat`.

The first entry takes priority over the ones listed below it.

### Callback List

Here is a list of callbacks your plugin can implement in its source code:

#### bool Addon_Load(void)

Called when the plugin is loaded. Can happen on initialisation, reload and so on.

#### void Addon_UnLoad(void)

Called when the plugin is being unloaded from memory. The chance for the plugin to remove anything it allocated that needs to be removed.

#### void Addon_Pause(void)

Called when plugin operation is halted.

#### void Addon_UnPause(void)

Called when plugin operation is resumed.

#### void Addon_LevelInit(string levelName)

Called upon level init, before entities are allowed to spawn.

#### void Addon_ServerActivate(void)

Called when the level has initialized the level fully. Entities are now able to spawn from here.

#### void Addon_GameFrame(void)

Called every frame on the server. As often as dictated by the server tic rate.

#### void Addon_LevelShutdown(void)

Called when the current level is being unloaded. This can happen during level transitions also.

#### bool Addon_ClientConnect(entity clientEntity)

Called when a client starts connecting to the current game session.

#### void Addon_ClientPutInServer(entity clientEntity)

Called when a client is being spawned into the game.

#### void Addon_ClientActive(entity clientEntity)

Called when a client is fully finished joining the current game session, after the game rules had a chance to work on the player.

#### void Addon_ClientDisconnect(entity clientEntity)

Called when the client disconnects from the server.

#### void Addon_ClientCommand(entity clientEntity, string commandString)

Called when the client enters a command into his console, which is then forwarded to the server. Gives the plugin to evaluate chat commands and more.

### Examples

The Nuclide source tree has some examples under `src/plugins/` if you need some tested, reference examples of AddonC.
