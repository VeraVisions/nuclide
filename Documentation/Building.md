# Building

## Building the Engine {#engine}
The **build_engine.sh** will do that for you. It will still ask you to have at least
a certain amount of dependencies installed (such as the **GCC**, **GNU make** and the **X11/SDL**
headers for your platform.

### Dependencies
* subversion
* gmake
* gcc
* mesa-libGL-devel
* libgnutls-devel
* libopenal-devel
* libX11-devel
* libXcursor-devel
* libXrandr-devel
* libSDL2-devel (only if you pass BUILD_SDL2=1 in build.cfg)

## Building the Level Editor {#editor}
Handled by **build_editor.sh**.

### Dependencies
* gcc-c++
* gtk2-devel
* gtkglext-devel
* libxml2-devel
* libjpeg8-devel
* minizip-devel

## Building Game-Logic {#game}
You can build the game source tree with **build_game.sh**. 

The script also takes a parameter. If you specify:

`./build_game.sh valve`

then it will only build the game-logic for the `valve` directory.

Otherwise, it will iterate through all of the game directories, look for a Makefile and build its default target.

It'll try use the **fteqcc** binary that's in the *./bin/* directory.
So make sure to build run **build_engine.sh** first.
Some distributions may carry the **fteqcc** compiler, but it usually is a very ancient version
that's probably not going to build any of this.

## Custom Configuration {#config}
There's a **build.cfg** file with which you can tweak build parameters of the various **build_** scripts.
For example, this is where you select between X11 and SDL2 builds. There you can specify which engine revision
you want to build and also which plugins you want to build along with it.
It's well commented, so I encourage you to check it out. However on some platforms, changing those settings
might introduce additional setup/dependency steps.

## Additional Information {#notes}
The game-logic is written in QuakeC, it is thus platform and architecture independent.

You do not need to rebuild the logic for each and every platform.
The results will be identical.
