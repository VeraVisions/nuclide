# Getting started

## How to get the latest version {#how}

You clone the Nuclide git repository first. There's multiple places to get it, one such place may be [code.idtech.space](https://code.idtech.space/):

`git clone https://code.idtech.space/vera/nuclide`

![](application_osx_terminal.png) You can then update the git repository as you normally would. Using `git pull`, or the built-in `make update` which will additionally update third-party repos and - when specified - a game directory.

If you need to build engine binaries, you can [get started on building the engine and the rest of the toolchain](@ref building) now.

Alternatively, you can also move in the official [FTE](https://www.fteqw.org/) binaries into the **Nuclide** directory to get started *without* bootstrapping your own engine + QuakeC compiler.

@note C programming knowledge is not required to use Nuclide itself.

## Running the game

Once you've built your engine binary or grabbed an existing compile from [FTE](https://www.fteqw.org/) its website, you should [proceed building the game-logic](@ref build-game).

You can then [run the client](@ref launching) and you should see the game window open right away.

![Test Game - aka Nuclide 'Base'](nuclide-base.png)

## Modifying the game

![](brick.png) In **Nuclide**, the main design goal is to have **Objects** included that do most of the work for you. You then use external, plain text files (referred to as 'decl') to fine-tune the various aspects of them.
Just because you need a dedicated spawn point entity for a fearful enemy doesn't mean you have to recompile the source code. You can simply make a decl that declares itself to be a spawnpoint with a given classname.

![](table.png) You can [read up on decls in these docs](@ref decl) to find out how you can take advantage of them.

## Debugging {#debugging}

![](bug.png) The engine comes equipped with several commands useful for debugging.
Nuclide also contains some commands of its own that aim to make your work easier. Let's go over some important ones.

### Console {#console}

The console is the main interface to debugging the game. So one needs to learn how to invoke it. It can be opened by pressing **Shift** + **Escape** on your keyboard.

From here on you can find out the version of your engine by typing `version` and pressing **ENTER**:

![The Console](nuclide-console.png)

Which may be useful in determining which engine version you are using, in case you need to file bug reports with the engine. Make sure to attach a copy of your engine build config if you happen to use one.

Some other useful commands are `condump logfile.txt`, `find`, `clear` and `quit`. The console has support for search and auto-completion so take advantage of it to save time! You can also use the **scroll wheel** on your *mouse* or *trackball*, as well as the **Page Up**, **Page Down**, **Control + Home** and **Control + End** keys on your *keyboard*.

### Watchpoints

You can set watchpoints using `watchpoint_ssqc` and `watchpoint_csqc` for @ref SSQC and @ref CSQC respectively.
To set a watchpoint on an entity its field, like the 1st player in a singleplayer game, you could do this to track their health:

```
watchpoint_ssqc 1.health
```

@note **The number in front of the '.health' field is the entity number.** You can find those out with debug viewers such as `r_showfields 1`, or the output in the console when `g_logLevel` is set to `3`. There are some more commands listed below that will help you identify entity numbers.

### Poking

Much like with watchpoints, we can view entity fields as well as manipulate them right from the console.

```
poke_ssqc 1.health=42
```

Will set the 1st player's health to `42`. If you do not assign a value it'll instead print out the field its current value.

### Entity Data

You can list the entity data, specific to the level you are on, like so:

```
listEntitySpawnData 248
```

And the output will look a lot like:

```
]/listEntitySpawnData 248
Spawn data for func_breakable (248):
{
        "model"         "*13"
        "origin"                "-130 -456.53 190"
        "physdamagescale"               "1.0"
        "minhealthdmg"          "0"
        "disablereceiveshadows"         "0"
        "rendercolor"           "255 255 255"
        "renderamt"             "255"
        "rendermode"            "0"
        "renderfx"              "0"
        "pressuredelay"         "0"
        "explodemagnitude"              "0"
        "spawnobject"           "0"
        "nodamageforces"                "0"
        "gibdir"                "0 0 0"
        "explosion"             "0"
        "material"              "0"
        "health"                "1"
        "propdata"              "0"
        "PerformanceMode"               "0"
        "ExplodeRadius"         "0"
        "ExplodeDamage"         "0"
        "disableshadows"                "0"
        "classname"             "func_breakable"
}
```

Much like with *watchpoint* and *poke* commands, you need to specify which entity id you want to query. That is the only unique identifier every entity has.

### List Named Triggers

In your levels you may want to debug some of the map-logic in isolation. You can get a list of all available named entities set up to trigger events like so:

```
listTargets
```

The output will look a lot like this:

```
]/listTargets
214: ladder1 (func_useableladder)
250: chimes (info_target)
259: powerbox_button (func_button)
260: output_0 (triggerminion)
261: output_0 (triggerminion)
262: output_0 (triggerminion)
263: output_0 (triggerminion)
264: output_0 (triggerminion)
265: output_0 (triggerminion)
266: output_0 (triggerminion)
267: output_0 (triggerminion)
268: powerbox_spark (env_spark)
269: powerbux_hurt (trigger_hurt)
270: powerbox_beam (env_beam)
271: powerbox_light (light)
272: scary_sound (info_target)
274: electro_hum (info_target)
275: beam_start (info_target)
276: beam_end (info_target)
396: pigeon_sound (info_target)
```
Output format consists of `[entity-id]: targetname (classname)`. You can then use this information to **send messages** directly to any of them.


### Sending Messages

#### Conventional 'Trigger' Impulse

You can send a simple **trigger impulse** to any named entity:

```
trigger powerbox_light
```

And it will respond as if it was triggered naturally.

#### Advanced Input Signals

Sometimes, you may also want to trigger a specific **input** on an entity, which can be done with the `input` command like this:

```
input 248 SetColor "255 128 0"
```

Where the syntax is `input [entity-id] [input name] [data string]`.

@note For the list of available **Inputs**, check the documentation for your desired object. For example: func_areaportal

### Logging

By default, most logging in the console is limited to *errors* and *warnings*. They are colored red and yellow in the output respectively.

You can output additional information, which will be useful during object development by setting `g_logLevel` to the value of `3`. You will then see additional messages appear when entities receive signals, or run complicated logic and states of success.

