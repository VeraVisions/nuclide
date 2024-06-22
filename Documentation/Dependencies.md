# Dependencies

Here we *attempt* to document the dependencies you may require to
build certain aspects yourself, on various different platforms.

### Debian / Raspbian

#### FTEQW

```
> apt-get install libgl-dev gnutls-dev
```

#### SDL2

```
# apt-get install libsdl2-dev
```

#### GLX / X11 (part of libsdl2-dev)

```
# apt-get install libx11-dev libxcursor-dev libxrender-dev
```

#### Plugin: ODE

```
# apt-get install autoconf automake libtool
```

#### Plugin: FFMPEG

```
# apt-get install libavformat-dev libswscale-dev
```

### OpenBSD

#### FTE

```
# pkg_add git
```

#### SDL2

```
# pkg_add sdl2
```

#### Plugin: FFMPEG

```
# pkg_add ffmpeg
```

### Arch Linux

#### FTE

```
# pacman -S make gcc Xorg git
```

#### Plugin: ODE

```
# pacman -S zip automake autoconf
```

#### Plugin: FFMPEG

> [!important]
> You will have to manually build this plugin due to FFMPEG
> breaking ABI between releases and Arch's rolling release nature.

First install the legacy version of **ffmpeg**:

```
# pacman -S ffmpeg4.4
```

Then browse to `ThirdParty/fteqw/engine` and run this command: 

```
$ make plugins-rel NATIVE_PLUGINS="ffmpeg" AV_BASE=/usr/include/ffmpeg4.4/ AV_LDFLAGS="-l:libavcodec.so.58 -l:libavformat.so.58 -l:libavutil.so.56 -l:libswscale.so.5"
```

Last, copy over `fteplug_ffmpeg_*.so` to the root directory where the
engine binaries (and other plugins) are.

#### SDL2

```
# pacman -S sdl2
```

#### WorldSpawn

```
# pacman -S pkgconf gtk2 gtkglext
```

### OpenSUSE

#### Nuclide

```
# zypper in git 
```

#### FTE

```
# zypper in make gcc gcc-c++ mesa-libGL-devel libgnutls-devel alsa-devel libopus-devel speex-devel libvorbis-devel
```

#### SDL2

```
# zypper in libSDL2-devel
```

#### GLX / X11

```
# zypper in libX11-devel libXcursor-devel libXrandr-devel
```

#### Plugin: ODE

```
# zypper in autoconf automake libtool zip
```

#### Plugin: FFMPEG

```
# zypper in ffmpeg-4-libavformat-devel ffmpeg-4-libswscale-devel
```

#### Worldspawn

```
# zypper in make gtkglext-devel libxml2-devel libjpeg8-devel minizip-devel
```

### Fedora

#### FTE

```
# dnf install make gcc gcc-c++ mesa-libGL-devel gnutls-devel alsa-devel libopus-devel speex-devel libvorbis-devel
```

#### SDL2

```
# dnf install SDL2-devel
```

#### GLX / X11 (part of libsdl2-dev)

```
# dnf install libX11-devel libXcursor-devel libXrender-devel
```

#### Plugin: ODE

```
# dnf install autoconf automake libtool zip
```

#### Plugin: FFMPEG

> [!important]
> You will have to manually build this plugin due to FFMPEG
> breaking ABI between releases as well as install a custom repository
> since Fedora ships only latest versions of FFMPEG.

First, you will need to install the RPM Fusion if you
don't have it. We recommend reading their official guide:
https://rpmfusion.org/Configuration

Then, you can install the required version of FFMPEG:

```
# dnf install compat-ffmpeg4-devel
```

Now to build:

1. Browse to `ThirdParty/fteqw/engine`
2. Run this command: 

```
$ make plugins-rel NATIVE_PLUGINS="ffmpeg" AV_BASE=/usr/include/compat-ffmpeg4 AV_LDFLAGS="-l:libavcodec.so.58 -l:libavformat.so.58 -l:libavutil.so.56 -l:libswscale.so.5"
```

Last, copy over `fteplug_ffmpeg.so` to the root directory where the
engine binaries (and other plugins) are.

#### Worldspawn

```
# dnf install make pkgconf gtkglext-devel libxml2-devel libjpeg-turbo-devel minizip-devel
```
