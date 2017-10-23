# FreeCS
Free-software implementation of Counter-Strike running on the FTE QuakeWorld engine.

<img src="https://icculus.org/~marco/freecs/screens/screen1.png" alt="Screen 1" width="256" height="192"> <img src="https://icculus.org/~marco/freecs/screens/screen2.png" alt="Screen 2" width="256" height="192">

<img src="https://icculus.org/~marco/freecs/screens/screen3.png" alt="Screen 3" width="256" height="192"> <img src="https://icculus.org/~marco/freecs/screens/screen4.png" alt="Screen 4" width="256" height="192">

<img src="https://icculus.org/~marco/freecs/screens/portable.jpg" alt="Android Port" width="340" height="192">

# Goals
The goal of this project is to provide an open-source version of Counter-Strike 1.5.
Counter-Strike, being one of the most popular multiplayer games to exist, hasn't had
a free-software implementation done until now.

** This project distributes no assets from either Half-Life or Counter-Strike. You have to provide them yourself. **

** This project shares no code with the Half-Life SDK. The entities are re-creations based on descriptions on TWHL.info. **

** Read the HL SDK EULA to find out [why.](http://twhl.info/articulator.php?art=1) **

Five cool random things you can do with this:

1. Play/Host CS on virtually every platform.
2. Customize the game to whatever extent you like.
3. Create entirely new weapons!
4. Create completely new and refreshing gamemodes!
5. Have a guarantee to be able to play it 20 years into the future!

# Status
All the weapons are implemented, so are the gamemodes: 
- **Hostage Rescue** (cs)
- **Bomb Defusal** (de)
- **Assassination** (as)
- **Escape** (es)

The game is playable as long as you don't care about the radar/overview display.

# Installing
1. Get the newest copy of FreeCS by cloning or [clicking here](https://github.com/eukara/FreeCS/archive/master.zip)
2. Extract it to somewhere safe on your harddrive, where you have read/write access (for Windows users... this is not C:/Program Files)
3. Get the latest version of FTEQW from the [website](http://triptohell.info/moodles/) in binary from and put it into the FreeCS directory with default.fmf in it.
4. Download csv15full.exe and run it (Use Wine on *NIX - no the Linux Server zip does NOT contain all the assets).
5. Run csv15full.exe and install it into the FreeCS folder.
5. Run FTE QuakeWorld to play!

*Optional step: Copy the 'valve' folder from your Half-Life installation in order for all assets to show up*

**Most UNIX file systems are case-sensitive, so you'll want to rename the .wad files in the cstrike directory to be lowercase for now. This will fix most missing texture bugs! Yes, this problem will be adressed in the future. **

# Notes
You might get away with using the cstrike folder from the Steam version of Counter-Strike 1.6, or any older version
than 1.5 - but they are not supported. I will not try to recreate 1.6 or any other earlier versions specifically.
I may however add additional, optional features that will emulate behaviour of later versions of Counter-Strike.

# Support this project
Feel free to send pull requests and refresh my memory by suggesting missing features under the **Issues** tab!
If you would like me to spend more time on this project, consider donating to me via https://paypal.me/eukara
Any help is appreciated.

# Special Thanks
**Spike** - Creator of FTE QuakeWorld and FTEQCC [(Website)](http://fte.triptohell.info/)

**TWHL** - Mapping Community with CS/HL entity information [(Website)](http://twhl.info)

**This repository uses no content from Half-Life nor the original Counter-Strike, for credits
as to who created the ORIGINAL Counter-Strike, please visit** [WebArchive - counter-strike net](http://web.archive.org/web/20021016230745/http://counter-strike.net/csteam.html)
