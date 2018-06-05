# FreeCS
A free-software implementation of Counter-Strike running on the FTE QuakeWorld engine.

Join our IRC channel at chat.freenode.net #freecs!

**This implementation runs on Linux. WINE or a Windows machine is required to extract the CS 1.5 files. These files cannot be legally redistributed.**

# Goals
Although Counter-Strike is one of the most popular multiplayer games to exist, a free-software implementation has never been created. This project provides an open-source version of Counter-Strike 1.5 based closely on the original mod but with better usability and added optional features.

**This project distributes no assets from either Half-Life or Counter-Strike. You have to provide them yourself.**

**No code is shared with the Half-Life SDK. The entities are re-creations based on descriptions on TWHL.info.**

**Read the HL SDK EULA to find out** [why.](http://twhl.info/articulator.php?art=1)

Five cool features:

1. Play and host CS on virtually every platform!
2. Customize the game to whatever extent!
3. Create new weapons!
4. Create new and refreshing game modes!
5. A guarantee that the game will still be functional in the future!

# Status
All weapons are implemented along with the following game modes:
- **Hostage Rescue** (cs)
- **Bomb Defusal** (de)
- **Assassination** (as)
- **Escape** (es)

The game is playable as long as you don't care about the radar and overview display.

# [Installing](https://github.com/eukara/FreeCS/wiki/Installation)
1. Get the newest copy of FreeCS by cloning the repository or by [clicking here](https://github.com/eukara/FreeCS/archive/master.zip)
2. Extract it to somewhere safe on your hard drive, where you have read/write access (for Windows users... this is not C:/Program Files)
3. Get the latest binary form version of FTEQW from this [website](http://triptohell.info/moodles/) and put it into the FreeCS directory with default.fmf in it. [You can also build fteqw from source if you know how.](https://sourceforge.net/projects/fteqw/)
4. Download csv15full.exe from [FilePlanet](https://www.fileplanet.com/57255/50000/fileinfo/Counter-Strike-1.5-Full-Mod-Client-[Win32])
5. Run csv15full.exe and install it into the FreeCS folder. (Use Wine on *NIX! The Linux Server zip does NOT contain all the assets)
6. Run FTE QuakeWorld to play!

**Optional step:** Copy the 'valve' folder from your Half-Life installation in order for all assets to show up into the same directory as freecs, cstrike and the default.fmf!

**Most UNIX file systems are case-sensitive, so you'll want to rename the .wad files in the cstrike directory to lowercase. This will fix most missing texture bugs! This problem will be addressed in the future.**

**Dedicated Server Notes:** Get fteqwsv.exe and launch it with the following parameters:

`fteqwsv.exe +sv_public 1 +map cs_assault`

cs_assault can be replaced with any map.

# Notes
Although the cstrike folder from versions older than 1.5 or the Steam version of Counter-Strike 1.6 may work, they are not supported.
A recreation of the other Counter-Strike version will not be implemented **YET**.
However, additional optional features emulating the behaviour of later versions of Counter-Strike may be implemented.
For example:
* Adding a way for server owners to configure whether or not buying a weapon automatically buys ammo (like in Counter-Strike: Source).

# Support this project
Feel free to send pull requests and refresh my memory by suggesting missing features under the **Issues** tab!
If you would like more time to be spent on this project, consider donating to my [PayPal](https://paypal.me/eukara).
However, your contribution to testing and reporting problems to me is already a great deal of support.

This is a one-man side-project, so keep that in mind before commenting...
Anyways, any help is appreciated!

# Special Thanks
**Spike** - Creator of FTE QuakeWorld and FTEQCC [(Website)](http://fte.triptohell.info/)

**TWHL** - Mapping Community with CS/HL entity information [(Website)](http://twhl.info)

**This repository uses no content from Half-Life nor the original Counter-Strike. For credits
to the ORIGINAL creators of Counter-Strike, please visit** [WebArchive - counter-strike net](http://web.archive.org/web/20021016230745/http://counter-strike.net/csteam.html)
