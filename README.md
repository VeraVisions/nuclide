# ![FTE Logo](Documentation/fte.svg) Nuclide - Software Development Kit 

Software Development Kit, built around idTech with focus on advanced features and
clean-room implementations of true-and-tested game-logic frameworks.
It's been used to ship a commercial product. So it's proven to some extent.

All of this is written in QuakeC, but there's also some GLSL and shell scripts
in here. If you and our team is unfamilar with any of these, you may want something else.

You can integrate an engine (FTE) and level design tool (WorldSpawn) directly from this tree. *See the 'Building' section for details.*
They're the projects actually based on idTech (GPL) code and therefore are in their own repositories.
If you're unfamilar with any of these, you may want something else.

**All the code here is ISC-Licensed.**

It's provided here under the terms of that license. You can have it - do what you like with it. Please don't barge in and demand help, support or hand-holding assistance unless you're going to offer us a good rate ($$$) for it. This is all provided AS-IS. It works for plenty of people, but might not for you!

## Features
* Reference codebase for first-person shooters in FTEQW, from scratch
* Has support for 100+ entities found in games such as Quake, Half-Life and Source SDK
* Support for player movement prediction and weapon prediction, for smooth online play
* AI system that's designed to be extendable for both singleplayer and multiplayer (BotLib)
* Waypoint editor
* UI toolkits for both 2D and in-world 3D drawing, like you'd see in Doom III
* Plugins system so that modders can write external plugins that hook into virtually every game
* Plenty of example projects available

## Building
The 'build_engine.sh' script checks out the **FTE Subversion** repository and keeps it up to date,
while also building binaries that are crucial to running and building the game-logic
(which is all QuakeC, to re-iterate) and putting them into the ./bin directory.
Launch the engine with the 'nuclide' and 'nuclide-ds' scripts.

On Windows, please use cygwin, MSYS2 or something for a sensible experience. If that doesn't work you can always resort to WSL. We have no plans on supporting Windows natively, as we don't do development on Windows.

The 'build_editor.sh' script clones the **WorldSpawn** Git repository and installs them into the ./bin directory.
Use the 'worldspawn' and 'vmap' scripts to launch to ensure consistency.

The 'build_game.sh' script will build the game-logic for the games included
using the QuakeC compiler present in the ./bin directory.
If the compiler isn't found it will ask you to build them. If you are running an operating system that has 'fteqcc' in its repositories, it may very well be out of date.

For best results, symlink the desired scripts into your home directory's bin folder.
The scripts are designed to be aware of their actual location in the filesystem.

## Packages
This is a development environment/framework. There are will be no binary packages.

## Dependencies

Rough list of dependencies for the average Linux system.
On some systems the names may slightly differ. These should be correct for OpenSUSE.

### Engine
* subversion
* gmake
* gcc
* mesa-libGL-devel
* libgnutls-devel
* libopenal-devel
* libX11-devel
* libXcursor-devel
* libXrandr-devel
* libSDL2-devel (only if you pass BUILD_SDL2=1 to build_engine.sh)

For WinNT and Darwin systems it's recommended you use the SDL2 backend, but native backends
may be available in FTEQW.

The X development packages are obviously only a requirement for when you do not compile an SDL2 build on a UNIX-like system.

Slackware users generally don't need to install anything, unless they explicitly diasable BUILD_ENGINE_DEPENDENCIES inside build.cfg.

### FFMPEG Plugin
* ffmpeg-4-libavformat-devel
* ffmpeg-4-libswscale-devel

You want this plugin if you want playback of a variety of media formats, including video decoding.
Building it can be disabled by editing build.cfg.

### Worldspawn Level Editor
* gcc-c++
* gtk2-devel
* gtkglext-devel
* libxml2-devel
* libjpeg8-devel
* minizip-devel

This is the only component that requires a C++ compiler.
Same as with Nuclide, don't bother us with support. It works for us but it may not work for you.
We cannot help you get other editors working for you. Generally you can use any .bsp format FTEQW supports anyway, so your choice of editor does not matter at all.

## Support
Join us in #nuclide on irc.libera.chat and chat if you're interested in using this in production.
**All this is provided to you for free and as-is otherwise.**

## Special Thanks
To id software and specifically John Carmack for having released the sources of
various idTech games under the GPL2 license, without which we would have no engine for Nuclide.

David Walton for **FTEQW** and the **FTEQCC** compiler, which is the brain of this SDK.

Timothee Besset and the **GtkRadiant** contributors, as well as the NetRadiant team for giving us a base for our editor **WorldSpawn**.

![idTech Logo](Documentation/idtech.svg)

## License
Copyright (c) 2016-2022 Vera Visions L.L.C.

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
