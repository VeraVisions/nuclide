# Bots

Bots are handled by BotLib, located under `src/botlib` in the directory tree.

Nuclide's BotLib takes some inspiration from **Quake III Arena** its bots, but shares no code or specific ideas or implementations. We do not use **AAS** for navigation, we leverage the route/pathfinding system **FTEQW** provides. Bots also share some code with regular NPC/Monster type entities through the use of the NSNavAI class.

Games are allowed to handle how they want to integrate bots themselves, but for development purposes there are ways to force bots to spawn.

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

See `platform/cvars.cfg` under the `// bots` section.