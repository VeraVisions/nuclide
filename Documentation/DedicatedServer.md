# Dedicated Server

# Usage

To initialize a dedicated server, you can run `./nuclide-ds -game yourGame`. It is generally advised to write and execute a server config file you have prepared ahead of time.

Here is an example:

```
hostname "Nuclide Test Server"
set sv_public 2      // 0 - not public, 1 = advertised on master server, 2 = ICE
set deathmatch 1     // request multiplayer modus
set coop 0           // deny coop modus
set maxplayers 16    // 16 players max
set timelimit 10     // 10 minutes per map
set fraglimit 30     // 30 frags per map
set pausable 0       // don't allow players to 'pause'
set rcon_password "" // no rcon
map dm_beck16        // start
```

You can then run the dedicated server like this:

`./nuclide-ds -game yourGame +exec server.cfg`

In production, the exact same style of commands applies to release builds. So if you have a standard engine binary (**fteqwgl64.exe** or a branded executable) things will be identical.

Keep in mind to set any game specific console variables.

# Remote Console (RCon)

In the above config, if you've set rcon_password to anything other than `""` you have access to remotely control the game server.

For example, you can (as a client, once connected) use the command `rcon yourPassword changelevel dm_beck16` to forcefully change the level on the server. Anything that's possible in a conventional dedicated server console is now accessible.