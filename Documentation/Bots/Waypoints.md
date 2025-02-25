# Bots {#bots}

## Bot Waypoints {#bot_waypoints}

Bots will read from the same navmesh as the rest of the artificial intelligence.

You can edit the navmesh using the `way_menu` command.

![Nuclide's way_menu Interface](nuclide-way.png)

You can then use the `slot` keys (usually bound to numbers **1** - **9** including **0**) to navigate the menu.

### Nodes

Nodes make up the smallest part of the navmesh, but they define all the paths that are walkable.

### Links

Links are connections between nodes. You can have as many links between nodes as you wish.
Those connections being made can also have special **flags**.

![Flags available on links](nuclide-way-flags.png)

The **Jump** flag will ensure that the bot will jump when it hits **point A**, before arriving at **point B**. You want to ensure those nodes are close to the edge of a gap for example.

The **Crouch** flag will force the bot to crouch while traversing **point A** to **point B**.

The **Walk** flag will force the bot to walk while traversing **point A** to **point B**.

The **Aim** flag will force the bot to forcefully look at the next node directly while traversing **point A** to **point B**. This is useful to control where they're looking at in order to make [ladders](@ref func_ladder) climbable by them.

The **Use** flag will trigger the bot into simulating a **use** action (simular to `+use`) to the nearest usable object in proximity of **point A**.

The **Hazardous** flag will mark a path between two points as dangerous, and thus will be avoided by bots at specific times.
