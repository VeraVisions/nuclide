# OpenCS
Open-Source implementation of CS running on FTE QuakeWorld

# Goals
The goal of this project is to provide an open-source implementation of Counter-Strike 1.5.
Counter-Strike, being one of the most popular multiplayer games to exist, surprisingly hasn't had
a free-software implementation done until now. 

Some of the cool things you can do with this:
* Play/Host CS and CS Servers on virtually every platform. ( Main selling point )
* Customize the game to whatever extent you like.
* Create entirely new weapons!
* Create completely new and refreshing gamemodes!
* Have a guarantee to be able to play it 20 years into the future!
* Use it as a base for your own games/mods! (As long as you own the rights to the assets)

# Status
All the weapons are implemented, but only hostage rescue maps are supported at the moment.
No equipment is implemented, no map radar/overview and no player animations.
Basically, hostage rescue is playable as long as you don't care about grenades/kevlar.

# Compiling/Installing
1. Download the latest version of FTE QuakeWorld.
2. Download csv15full.exe and to get the cstrike folder.
3. Move both the cstrike folder and FTE QuakeWorld into a folder
4. Compile the Client and Server modules using FTEQCC and put them into the cstrike folder
5. Run FTE QuakeWorld

# Special Thanks
Spike - Creator of FTE QuakeWorld and FTEQCC ( http://fte.triptohell.info/ )

TWHL - Mapping Community with CS/HL entity information (  http://twhl.info )

This repository uses no content from Half-Life nor the original CS, for credits
as to who created the ORIGINAL Counter-Strike, please visit
http://web.archive.org/web/20021016230745/http://counter-strike.net/csteam.html
