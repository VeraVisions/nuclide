# Bots {#bots}

## Console Commands {#bot_commands}

### addBot [profile name]

Adds a bot to the current game.

### killAllBots

Force kills and respawns bots in the current game.

### resetAllBotsGoals

Force reset bots current trajectory and goals.

## Bot Console Variables

### bot_enable
Enable (1) or disable (0) usage of bots in the game. Default is 1.

### bot_pause
Enable (1) or disable (0) an interrupt for the Bot AIs thinking. Default is 0.

### bot_noChat
Enable (1) or disable (0) a suppression of any bot chatter. Default is 0.

### bot_fastChat
Enable (1) or disable (0) bot chatter that does not stop other inputs. Default is 0.

### bot_debug
Enable (1) or disable (0) bot debug features that otherwise won't work. Default is 0.

### bot_developer
Enable (1) or disable (0) bot debug text in console. Default is 0.

### bot_minClients
When set, ensures to fill the server with this many players/bots. Default is -1.

### bot_aimless
Enable (1) or disable (0) bot not knowing where to go. Will keep generating a new place to walk to.

### bot_crouch
Enable (1) or disable (0) the forcing of bots crouching down.

### bot_walk
Enable (1) or disable (0) the restriction of bots to walking speed.

### bot_prone
Enable (1) or disable (0) the forcing of bots to crawl/prone.

### bot_dont_shoot
Enable (1) or disable (0) bot pacifist mode.
