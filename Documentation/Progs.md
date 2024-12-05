# Progs {#progs}

Progs are binary files containing bytecode that contain platform and architecture
indepenent programs.

We generally refer to them as **progs**.

Our SDK is built using QuakeC as the language of choice, as that's where
the engine-provided API is the most powerful and there is a great
deal of history of games using it.

## Server-Side QuakeC {#SSQC}

The main game-logic module, first introduced with **Quake (1996)**.
It is involved with the core game entities, triggers, and decides what
monsters, items and weapons are allowed in the game and how they are used.
In Nuclide, the server game is tightly coupled with @ref entitydef to
make everything streamlined for content creators and developers alike.

## Client-Side QuakeC {#CSQC}

Largely responsible for visual effects and the overall presentation.
A large chunk of the client-side code is spent executing shared code
between client and server. Player movement, weapons and vehicle input
is shared between client and server to ensure smooth network play.

## Additional Progs

We offer multiple types of progs the game-logic can load/unload at runtime.

You will generally find them within your `<gamedir>/progs` directory.

They are optional. So if you want to handle everything internally, you can.

But if you're worried about keeping up with changes, you may want to depend on their stable APIs and extend your game using modules as the main method of feature-injection.

- ![](monitor_go.png) [HudC](@ref hudC) powers our client-side, hot-pluggable **heads-up-display**.
- ![](plugin_go.png) [AddonC](@ref addonC) is our server-side **plugin** system.
- ![](map_go.png) [MapC](@ref mapC) handles server-side **map-oriented** tasks and logic.
- ![](script_go.png) [RuleC](@ref ruleC) is responsible for the shared, **global set of game-rules**.

