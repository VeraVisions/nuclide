# Multiplayer Systems {#mp}

## Remote Administration (RCon) System {#rcon}

Not a Nuclide specific feature, but you can make use of **rcon** to control a game-server from within a client or a third-party **rcon** utility.

### Console Variables

#### rcon_password [string]

Sets the **rcon** password to the given string.

#### rcon_address

When empty, will send **rcon** commands to the current server.
Otherwise, commands issued with [rcon](@ref rcon_cmd)

### Console Commands

#### rcon [...] {#rcon_cmd}

Executes a command as the server. Only possible when rcon_password is set to the same value on client & server console.