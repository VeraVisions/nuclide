# Bots

Bots are CPU controlled opponents. They can be useful for development, debugging but can also fun to play with.

They're fake clients, traversing the level, and acting upon objectives they either figure out themselves, or are told to to act a certain way.

We encourage any multiplayer game to support them, because they often also fill in the function of balancing teams. There's a whole slew of benefits of supporting bots, and players will generally thank you for including them.

## Technical Info

Bots are handled by BotLib, located under `src/botlib/` in the source tree.

Nuclide's BotLib takes some inspiration from **Quake III Arena** its bots, but shares no code or specific ideas or implementations. We do not use **AAS** for navigation, we leverage the route/pathfinding system **FTEQW** provides. Bots also share some code with regular NPC/Monster type entities through the use of the NSNavAI class.

Games are allowed to handle how they want to integrate bots themselves, but for development purposes there are ways to force bots to spawn also.

# Bot profiles

Nuclide has support for bot profiles, like in **Quake III Arena**. They work differently although they appear compatible by design. You can define them in a script that looks something like this and is located at `scripts/bots.txt` in your game directory:

```
{
	name Albert
	model zombie01
	topcolor 0xeff
	bottomcolor 0xff0020
}
{
	name Susie
	model police02
	topcolor 0xff6b00
	bottomcolor 0xff0b00
}
{
	name Dog
	funname ^4D^2o^1g
	model dog01
	topcolor 0x9200ff
	bottomcolor 0xc800ff
}
```

Only the `name` key is required. The only other special key is `funname` which sets the nickname to be different from the internal name. The other keys are set as user info (setinfo) keys on the bot client.

This will allow games to add whatever extra keys they wish that they can then recognize anywhere in the client/server codebase. No additional networking or APIs necessary. Simply query bot properties via their userinfo.

# Bot Console Commands

## addBot [profile name]

Adds a bot to the current game.

## killAllBots

Force kills and respawns bots in the current game.

## resetAllBotsGoals

Force reset bots current trajectory and goals.

# Bot Console Variables

## bot_enable
Enable (1) or disable (0) usage of bots in the game. Default is 1.

## bot_pause
Enable (1) or disable (0) an interrupt for the Bot AIs thinking. Default is 0.

## bot_noChat
Enable (1) or disable (0) a suppression of any bot chatter. Default is 0.

## bot_fastChat
Enable (1) or disable (0) bot chatter that does not stop other inputs. Default is 0.

## bot_debug
Enable (1) or disable (0) bot debug features that otherwise won't work. Default is 0.

## bot_developer
Enable (1) or disable (0) bot debug text in console. Default is 0.

## bot_minClients
When set, ensures to fill the server with this many players/bots. Default is -1.

## bot_aimless
Enable (1) or disable (0) bot not knowing where to go. Will keep generating a new place to walk to.

## bot_crouch
Enable (1) or disable (0) the forcing of bots crouching down.

## bot_walk
Enable (1) or disable (0) the restriction of bots to walking speed.

## bot_prone
Enable (1) or disable (0) the forcing of bots to crawl/prone.

## bot_dont_shoot
Enable (1) or disable (0) bot pacifist mode.
