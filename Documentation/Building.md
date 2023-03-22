# Building

## Preface

If you don't plan on modifying the engine, then you probably shouldn't! You can grab binaries from [FTEQW](https://www.fteqw.org) and move them into the Nuclide directory under `./bin`. 

If you're on Microsoft Windows, you will most likely not be running the `nuclide` launch script anyway, so feel free to move the `fteqw.exe` into the root of the Nuclide directory, and run that as-is instead. 

It will mount the game directories specified in the `default.fmf` file, which you can tweak as needed. [For more information, read the relevant documentation regarding launching Nuclide](Documentation/Launching.md)

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
apt-get install libgl-dev gnutls-dev
```

#### SDL2

```
apt-get install libsdl2-dev
```

#### GLX / X11 (part of libsdl2-dev)

```
apt-get install libx11-dev libxcursor-dev libxrender-dev
```

#### Plugin: ODE

```
apt-get install autoconf automake libtool
```

#### Plugin: FFMPEG

```
apt-get install libavformat-dev libswscale-dev
```

### OpenBSD

#### FTE

```
pkg_add git
```

#### SDL2

```
pkg_add sdl2
```

#### Plugin: FFMPEG

```
pkg_add ffmpeg
```

### Arch Linux

#### FTE

```
pacman -S make gcc Xorg git
```

#### Plugin: ODE

```
pacman -S zip automake autoconf
```

#### Plugin: FFMPEG

```
pacman -S ffmpeg4.4
```

*Note:* You will have to manually build this plugin due to FFMPEG breaking ABI between releases and Arch's rolling release nature. 

1) Edit build.cfg and change `FFMPEG=YES` to `NO`
2) Browse to src/engine/engine
3) Run this command: 

`make plugins-rel NATIVE_PLUGINS="ffmpeg" AV_BASE=/usr/include/ffmpeg4.4/ AV_LDFLAGS="-l:libavcodec.so.58 -l:libavformat.so.58 -l:libavutil.so.56 -l:libswscale.so.5"`

4) Copy over `fteplug_ffmpeg.so` to the `bin` folder where nuclide and the build scripts are.


#### SDL2

```
pacman -S sdl2
```

#### WorldSpawn

```
pacman -S pkgconf gtk2 gtkglext
```

### OpenSUSE

#### Nuclide

```
zypper in git 
```

#### FTE

```
zypper in make gcc gcc-c++ mesa-libGL-devel libgnutls-devel
```

#### SDL2

```
zypper in libSDL2-devel
```

#### GLX / X11

```
zypper in libX11-devel libXcursor-devel libXrandr-devel
```

#### Plugin: FFMPEG

```
zypper in ffmpeg-4-libavformat-devel ffmpeg-4-libswscale-devel
```

#### Worldspawn

```
zypper in make gtkglext-devel libxml2-devel libjpeg8-devel minizip-devel
```

### Fedora

#### FTE

```
dnf install make gcc gcc-c++ mesa-libGL-devel gnutls-devel
```

#### SDL2

```
dnf install SDL2-devel
```

#### GLX / X11 (part of libsdl2-dev)

```
dnf install libX11-devel libXcursor-devel libXrender-devel
```

#### Plugin: ODE

```
dnf install autoconf automake libtool
```

#### Plugin: FFMPEG

*Note:* You will have to manually build this plugin due to FFMPEG breaking ABI between releases as well as install a custom repository since Fedora ships only latest versions of FFMPEG. 

First, you will need to install the RPM Fusion if you don't have it. We recommend reading their official guide: https://rpmfusion.org/Configuration

Then, you can install the required version of FFMPEG:

```
dnf install compat-ffmpeg4-devel
```

Now to build:

1) Edit build.cfg and change `FFMPEG=YES` to `NO`
2) Browse to src/engine/engine
3) Run this command: 

`make plugins-rel NATIVE_PLUGINS="ffmpeg" AV_BASE=/usr/include/compat-ffmpeg4 AV_LDFLAGS="-l:libavcodec.so.58 -l:libavformat.so.58 -l:libavutil.so.56 -l:libswscale.so.5"`

4) Copy over `fteplug_ffmpeg.so` to the `bin` folder where nuclide and the build scripts are.

#### Worldspawn

```
dnf install make pkgconf gtkglext-devel libxml2-devel libjpeg-turbo-devel minizip-devel
```