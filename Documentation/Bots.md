# Bots {#bots}

Bots are CPU controlled opponents. They can be useful for development, debugging but can also fun to play with.

They're fake clients, traversing the level, and acting upon objectives they either figure out themselves, or are told to to act a certain way.

We encourage any multiplayer game to support them, because they often also fill in the function of balancing teams. There's a whole slew of benefits of supporting bots, and players will generally thank you for including them.

## Technical Info

Bots are handled by BotLib, located under `src/botlib/` in the source tree.

Nuclide's BotLib takes some inspiration from **Quake III Arena** its bots, but shares no code or specific ideas or implementations. We do not use **AAS** for navigation, we leverage the route/pathfinding system **FTEQW** provides. Bots also share some code with regular NPC/Monster type entities through the use of the NSNavAI class.

Games are allowed to handle how they want to integrate bots themselves, but for development purposes there are ways to force bots to spawn also.
