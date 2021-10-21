# ![FTE Logo](doc/fte.svg) Nuclide - Software Development Kit 

Software Development Kit, built around idTech with focus on advanced features and
clean-room implementations of true-and-tested game-logic frameworks.

All of this is written in QuakeC, but there's also some GLSL and shell scripts
in here.

You can integrate an engine (FTE) and level design tool (WorldSpawn) directly from this tree. *See the 'Building' section for details.*
They're the projects actually based on idTech (GPL) code and therefore are in their own repositories.
**All the code here is ISC-Licensed.**

The advantage of our centralized model is that the toolchain more or less integrates
with the engine seamlessly. This avoids a common problem developers have of trying to
use tools primarily designed for one specific idTech game with a custom
engine that's trying to do more advanced stuff than the former.

## Building
The 'build_engine.sh' script checks out the **FTE Subversion** repository and keeps it up to date,
while also building binaries that are crucial to running and building the game-logic
(which is all QuakeC) and putting them into the ./bin directory.
Launch the engine with the 'nuclide' and 'nuclide-ds' scripts.

On Windows, please use cygwin for a sensible experience.

The 'build_editor.sh' script clones the **WorldSpawn** Git repository and installs them into the ./bin directory.
Use the 'worldspawn' and 'vmap' scripts to launch to ensure consistency.

The 'build_game.sh' script will build the game-logic for the games included
using the QuakeC compiler present in the ./bin directory.
If the compiler isn't found it will ask you to build them.

For best results, symlink the desired scripts into your home directory's bin folder.
The scripts are designed to be aware of their actual location in the filesystem.

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

### FFMPEG Plugin
* ffmpeg-4-libavformat-devel
* ffmpeg-4-libswscale-devel

You want this plugin if you want playback of a variety of media formats, including video decoding.

### Worldspawn Level Editor
* gcc-c++
* gtk2-devel
* gtkglext-devel
* libxml2-devel
* libjpeg8-devel
* minizip-devel

This is the only component that requires a C++ compiler. 

## Support
Join us in #nuclide on irc.libera.chat and chat if you're interested in using this in production.
**All this is provided to you for free as-is otherwise.**

## Special Thanks
To id software and specifically John Carmack for having released the sources of
various idTech games under the GPL2 license, without which we would have no engine for Nuclide.

David Walton for **FTEQW** and the **FTEQCC** compiler, which is the brain of this SDK.

Timothee Besset and the **GtkRadiant** contributors.

![idTech Logo](doc/idtech.svg)

## License
Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>

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
