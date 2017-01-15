# FreeCS
Open-Source implementation of Counter-Strike running on the FTE QuakeWorld engine.

<img src="https://icculus.org/~marco/opencs/screenshots/fte-20170113225215-0.png" alt="Screen 1" width="320" height="240"> <img src="https://icculus.org/~marco/opencs/screenshots/fte-20170113225158-0.png" alt="Screen 2" width="320" height="240">

<img src="https://icculus.org/~marco/opencs/screenshots/fte-20170113225827-0.png" alt="Screen 3" width="320" height="240"> <img src="https://icculus.org/~marco/opencs/screenshots/fte-20170113225528-0.png" alt="Screen 4" width="320" height="240">

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
All the weapons are implemented, so are the gamemodes: Hostage Rescue (cs), Bomb Defusal (de), Assassination (as) and Escape (es).
Not all equipment is implemented and no map radar/overview is recreated.
Basically, the game is playable as long as you don't care about grenades (for now).

# Installing
1. Download the latest version of FTE QuakeWorld.
2. Download csv15full.exe and to get the cstrike folder.
3. Move both the cstrike folder and FTE QuakeWorld into a folder
4. Clone this repository into that same folder, so that freecs, default.fmf and cstrike co-exist
5. Run FTE QuakeWorld

Optional step: Copy the 'valve' folder from your Half-Life installation in order for all features to work.

# Notes
You might get away with using the cstrike folder from the Steam version of Counter-Strike 1.6, or any older version
than 1.5 - but they are not supported. I will not try to recreate 1.6 or any other earlier versions specifically.
I may however add additional, optional features that will emulate behaviour of later versions of Counter-Strike.

# Special Thanks
Spike - Creator of FTE QuakeWorld and FTEQCC ( http://fte.triptohell.info/ )

TWHL - Mapping Community with CS/HL entity information (  http://twhl.info )

This repository uses no content from Half-Life nor the original Counter-Strike, for credits
as to who created the ORIGINAL Counter-Strike, please visit
http://web.archive.org/web/20021016230745/http://counter-strike.net/csteam.html
