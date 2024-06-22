# Multiplayer Systems {#mp}

## Voting System {#voting}

When the console variable `mp_allowvote` is set to 1, players are allowed access to the `callvote` command.  

They have access to the following subcommands:

### callvote map [mapname]

Will request a map change to the proposed map. Will alert when the map does not exist on the server.

### callvote kick [player id]

Requests a player to be kicked.

### callvote timelimit

Requests an adjustment to the timelimit.

### callvote fraglimit

Requests an adjustment to the fraglimit.

### callvote map_restart

Requests the map to restart, without altering the [map cycle](@ref mapcycle).

### callvote nextmap

Requests a change to the next map.
