# Singleplayer Systems {#sp}

## Nodegraph System {#nodegraph}

The **Nodegraph** is the navigation mesh used by the majority of the singleplayer AI.

Unlike [waypoints for bots](@ref bot_waypoints), the node graph is generated automatically by the game-logic out of entities, such as info_node and info_node_air.

The resulting node graph is then stored under `gamedir/data/MAPNAME.way`.

It is stored in the format required by the engine to perform routing calculations for us.
