# Building

## Building the Engine {#engine}

The **build_engine.sh** will do that for you. It will still ask you to have at least
a certain amount of dependencies installed (such as the **GCC**, **GNU make** and the **X11/SDL**
headers for your platform.

### Optional: Building release binaries

You'll have to manually go into `src/engine/engine` and issue:

```
$ make m-rel FTE_CONFIG=yourgameconfig
```

If you want to cross-compile to different platforms, you can pass the `FTE_TARGET` variable and select from **win32**, **win64**, **linux32**, **linux64** or **SDL2**.

For example, this will build a release binary of **The Wastes** for Win32, using the configuration specified inside `src/engine/engine/common/config_wastes.h`:

```
$ make m-rel FTE_CONFIG=wastes FTE_TARGET=win32
```

The resulting binary can be found inside the `src/engine/engine/release` directory.

**Note**: The **SDL2** target will require you to set the **ARCH** environment to the target of your choosing.

## Building the Level Editor {#editor}

Handled by **build_editor.sh**.

## Building Game-Logic {#game}

You can build the game source tree with **build_game.sh**. 

The script also takes a parameter. If you specify:

```
./build_game.sh valve
```

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

## Dependencies

### Debian / Raspbian

#### FTE

```
apt-get install subversion libgl-dev gnutls-dev
```

#### SDL2

```
apt-get install libsdl2-dev
```

#### GLX / X11 (part of libsdl2-dev)

```
apt-get install libx11-dev libxcursor-dev libxrender-dev
```

#### ODE Plugin

```
apt-get install autoconf automake libtool
```

#### FFMPEG Plugin

```
apt-get install libavformat-dev libswscale-dev
```

### OpenBSD

#### Nuclide

```
pkg_add git
```

#### FTE

```
pkg_add subversion
```

#### SDL2

```
pkg_add sdl2
```

#### FFMPEG Plugin

```
pkg_add ffmpeg
```

### OpenSUSE

#### Nuclide

```
zypper in git 
```

#### FTE

```
zypper in subversion make gcc gcc-c++ mesa-libGL-devel libgnutls-devel
```

#### SDL2

```
zypper in libSDL2-devel
```

#### GLX / X11

```
zypper in libX11-devel libXcursor-devel libXrandr-devel
```

#### FFMPEG Plugin

```
zypper in ffmpeg-4-libavformat-devel ffmpeg-4-libswscale-devel
```

#### Worldspawn

```
zypper in cmake gtkglext-devel libxml2-devel libjpeg8-devel minizip-devel
```
