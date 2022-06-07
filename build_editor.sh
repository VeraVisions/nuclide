#!/bin/sh
. ./build.cfg

mv_wsfile()
{
	if [ -f "./build/$1" ]
	then
		cp -v "./build/$1" "../../bin/$1"
	fi
}

mv_msysfile()
{
	if [ -f "./build/$1" ]
	then
		cp -v "./build/$1" "../../bin/$1"
	fi
}

if ! [ -x "$(command -v git)" ]
then
	printf "'git' is not installed.\n"
	exit
fi

set -e

WS_MAKEFILE=./src/worldspawn/Makefile
COMPILE_SYS=$(uname)
COMPILE_OS=$(uname -o)

# Check how many cores/processors we should use for building
if ! [ -x "$(command -v nproc)" ]
then
	# check if we're on OpenBSD then
	if ! [ -x "$(command -v sysctl)" ]
then
		BUILD_PROC=1
	else
		BUILD_PROC=$(sysctl -n hw.ncpu)
	fi
else
	BUILD_PROC=$(nproc)
fi

if [ "$BUILD_DEBUG" -eq 1 ]
then
	WS_CFLAGS="-g"
fi

# handle search directories and platform specific libraries
if [ "$COMPILE_SYS" = "OpenBSD" ]
then
	WS_CFLAGS="$WS_CFLAGS -I/usr/local/include -I/usr/local/include/gtkglext-1.0 -I/usr/local/lib/gtkglext-1.0/include -I/usr/local/include/libxml2/"
	WS_LDFLAGS="$WS_LDFLAGS -L/usr/local/lib"
	WS_CC=cc
	WS_CXX=c++
else
	WS_CFLAGS="$WS_CFLAGS"
	WS_LDFLAGS="$WS_LDFLAGS -ldl"

	if [ "$BUILD_CLANG" = "1" ]; then
		WS_CC=clang
		WS_CXX=clang++
	else
		WS_CC=gcc
		WS_CXX=g++
	fi
fi

if [ "$COMPILE_OS" = "Msys" ]; then
	WS_CC=cc
	WS_CXX=c++
	WS_CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
	WS_LDFLAGS="$LDFLAGS -lws2_32"
	WS_LIB_EXT=dll
fi

# GNU Make is _not_ make!...
if [ "$COMPILE_OS" = "Msys" ]; then
	MAKE=make
	PLATFORM=win64
else
	if ! [ -x "$(command -v gmake)" ]
	then
		# only assume that Linux may not ship with a gmake... HACK!
		if [ "$COMPILE_SYS" = "Linux" ]
		then
			MAKE=make
		else
			printf "You need to install GNU make.\n"
		fi
	else
		MAKE=gmake
	fi
fi

mkdir -p ./bin

if [ -f "$WS_MAKEFILE" ]
then
	if [ "$BUILD_UPDATE" -eq 1 ]
	then
		printf "WorldSpawn is present, updating...\n"
		cd ./src/worldspawn/
		git pull
	else
		cd ./src/worldspawn/
	fi
else
	printf "WorldSpawn is NOT present, cloning...\n"
	cd ./src/
	git clone https://git.code.sf.net/p/worldspawn/code worldspawn
	cd ./worldspawn
fi

if [ "$BUILD_CLEAN" -eq 1 ]
then
	$MAKE clean
fi

$MAKE -j $BUILD_PROC CC=$WS_CC CXX=$WS_CXX CFLAGS="$WS_CFLAGS" LDFLAGS="$WS_LDFLAGS" LIB_EXT=$WS_LIB_EXT


mkdir -p ../../bin/bitmaps
mv_wsfile defaultkeys.ini
mv_wsfile bitmaps/black.xpm
mv_wsfile bitmaps/brush_flipx.xpm
mv_wsfile bitmaps/brush_flipy.xpm
mv_wsfile bitmaps/brush_flipz.xpm
mv_wsfile bitmaps/brush_rotatex.xpm
mv_wsfile bitmaps/brush_rotatey.xpm
mv_wsfile bitmaps/brush_rotatez.xpm
mv_wsfile bitmaps/cap_bevel.xpm
mv_wsfile bitmaps/cap_curve.xpm
mv_wsfile bitmaps/cap_cylinder.xpm
mv_wsfile bitmaps/cap_endcap.xpm
mv_wsfile bitmaps/cap_ibevel.xpm
mv_wsfile bitmaps/cap_iendcap.xpm
mv_wsfile bitmaps/console.xpm
mv_wsfile bitmaps/copy.xpm
mv_wsfile bitmaps/cut.xpm
mv_wsfile bitmaps/dontselectcurve.xpm
mv_wsfile bitmaps/dontselectmodel.xpm
mv_wsfile bitmaps/ellipsis.xpm
mv_wsfile bitmaps/entities.xpm
mv_wsfile bitmaps/file_new.xpm
mv_wsfile bitmaps/file_open.xpm
mv_wsfile bitmaps/file_save.xpm
mv_wsfile bitmaps/icon.xpm
mv_wsfile bitmaps/lightinspector.xpm
mv_wsfile bitmaps/logo.xpm
mv_wsfile bitmaps/modify_edges.xpm
mv_wsfile bitmaps/modify_faces.xpm
mv_wsfile bitmaps/modify_vertices.xpm
mv_wsfile bitmaps/noFalloff.xpm
mv_wsfile bitmaps/notex.tga
mv_wsfile bitmaps/paste.xpm
mv_wsfile bitmaps/patch_bend.xpm
mv_wsfile bitmaps/patch_drilldown.xpm
mv_wsfile bitmaps/patch_insdel.xpm
mv_wsfile bitmaps/patch_showboundingbox.xpm
mv_wsfile bitmaps/patch_weld.xpm
mv_wsfile bitmaps/patch_wireframe.xpm
mv_wsfile bitmaps/popup_selection.xpm
mv_wsfile bitmaps/redo.xpm
mv_wsfile bitmaps/refresh_models.xpm
mv_wsfile bitmaps/scalelockx.xpm
mv_wsfile bitmaps/scalelocky.xpm
mv_wsfile bitmaps/scalelockz.xpm
mv_wsfile bitmaps/select_additive.xpm
mv_wsfile bitmaps/select_autoexpand.xpm
mv_wsfile bitmaps/selection_csgmerge.xpm
mv_wsfile bitmaps/selection_csgsubtract.xpm
mv_wsfile bitmaps/selection_makehollow.xpm
mv_wsfile bitmaps/selection_makeroom.xpm
mv_wsfile bitmaps/selection_selectcompletetall.xpm
mv_wsfile bitmaps/selection_selectinside.xpm
mv_wsfile bitmaps/selection_selectpartialtall.xpm
mv_wsfile bitmaps/selection_selecttouching.xpm
mv_wsfile bitmaps/select_mouseresize.xpm
mv_wsfile bitmaps/select_mouserotate.xpm
mv_wsfile bitmaps/select_mousescale.xpm
mv_wsfile bitmaps/select_mousetranslate.xpm
mv_wsfile bitmaps/shadernotex.tga
mv_wsfile bitmaps/show_entities.xpm
mv_wsfile bitmaps/side_edges.xpm
mv_wsfile bitmaps/side_faces.xpm
mv_wsfile bitmaps/side_vertices.xpm
mv_wsfile bitmaps/side_brush.png
mv_wsfile bitmaps/side_cut.png
mv_wsfile bitmaps/side_entities.png
mv_wsfile bitmaps/side_entspec.png
mv_wsfile bitmaps/side_move.png
mv_wsfile bitmaps/side_patch.png
mv_wsfile bitmaps/side_patchspec.png
mv_wsfile bitmaps/side_rotate.png
mv_wsfile bitmaps/side_scale.png
mv_wsfile bitmaps/side_select.png
mv_wsfile bitmaps/side_surfspec.png
mv_wsfile bitmaps/side_tex.png
mv_wsfile bitmaps/side_resize.png
mv_wsfile bitmaps/side_selectface.png
mv_wsfile bitmaps/side_selectwhole.png
mv_wsfile bitmaps/splash.xcf
mv_wsfile bitmaps/splash.xpm
mv_wsfile bitmaps/texture_browser.xpm
mv_wsfile bitmaps/texture_lock.xpm
mv_wsfile bitmaps/textures_popup.xpm
mv_wsfile bitmaps/undo.xpm
mv_wsfile bitmaps/view_cameratoggle.xpm
mv_wsfile bitmaps/view_cameraupdate.xpm
mv_wsfile bitmaps/view_change.xpm
mv_wsfile bitmaps/view_clipper.xpm
mv_wsfile bitmaps/view_cubicclipping.xpm
mv_wsfile bitmaps/view_entity.xpm
mv_wsfile bitmaps/white.xpm
mv_wsfile bitmaps/window1.xpm
mv_wsfile bitmaps/window2.xpm
mv_wsfile bitmaps/window3.xpm
mv_wsfile bitmaps/window4.xpm
mkdir -p ../../bin/games
mv_wsfile games/platform.game
mv_wsfile games/goldsrc.game
mkdir -p ../../bin/gl
mv_wsfile gl/lighting_DBS_omni_fp.glp
mv_wsfile gl/lighting_DBS_omni_fp.glsl
mv_wsfile gl/lighting_DBS_omni_vp.glp
mv_wsfile gl/lighting_DBS_omni_vp.glsl
mv_wsfile gl/lighting_DBS_XY_Z_arbfp1.cg
mv_wsfile gl/lighting_DBS_XY_Z_arbvp1.cg
mv_wsfile gl/utils.cg
mv_wsfile gl/zfill_arbfp1.cg
mv_wsfile gl/zfill_arbvp1.cg
mv_wsfile gl/zfill_fp.glp
mv_wsfile gl/zfill_fp.glsl
mv_wsfile gl/zfill_vp.glp
mv_wsfile gl/zfill_vp.glsl

mkdir -p ../../bin/platform.game
mv_wsfile platform.game/default_build_menu.xml
mkdir -p ../../bin/platform.game/platform
mv_wsfile platform.game/platform/entities.def
mkdir -p ../../bin/goldsrc.game
mv_wsfile goldsrc.game/default_build_menu.xml

mkdir -p ../../bin/plugins
if [ "$COMPILE_OS" = "Msys" ]; then
mv_wsfile plugins/libarchivezip.dll
mv_wsfile plugins/libarchivepak.dll
mv_wsfile plugins/libarchivewad.dll
mv_wsfile plugins/libentity.dll
mv_wsfile plugins/libimage.dll
mv_wsfile plugins/libimagehl.dll
mv_wsfile plugins/libiqmmodel.dll
mv_wsfile plugins/libmapq3.dll
mv_wsfile plugins/libmodel.dll
mv_wsfile plugins/libshaders.dll
mv_wsfile plugins/libmatsys.dll
mv_wsfile plugins/libvfspk3.dll
mv_wsfile plugins/libbrushexport.dll
mv_wsfile plugins/libprtview.dll
mv_wsfile worldspawn.exe
mv_wsfile vmap.exe
cd ../../bin/
ldd worldspawn.exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp -v "{}" .
ldd vmap.exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp -v "{}" .
ldd plugins/* | grep '\/mingw.*\.dll' -o | xargs -I{} cp -v "{}" .
cp -r /c/msys64/mingw64/bin/zlib1.dll ./zlib1.dll
cp -r /c/msys64/mingw64/bin/libdatrie-1.dll ./libdatrie-1.dll
ldd *.dll | grep '\/mingw.*\.dll' -o | xargs -I{} cp -v "{}" .
cd ..
cp -r /c/msys64/mingw64/lib/gdk-pixbuf-2.0/ ./lib/
else
mv_wsfile plugins/libarchivezip.so
mv_wsfile plugins/libarchivepak.so
mv_wsfile plugins/libarchivewad.so
mv_wsfile plugins/libentity.so
mv_wsfile plugins/libimage.so
mv_wsfile plugins/libimagehl.so
mv_wsfile plugins/libiqmmodel.so
mv_wsfile plugins/libmapq3.so
mv_wsfile plugins/libmodel.so
mv_wsfile plugins/libshaders.so
mv_wsfile plugins/libmatsys.so
mv_wsfile plugins/libvfspk3.so
mv_wsfile plugins/libbrushexport.so
mv_wsfile plugins/libprtview.so
mv_wsfile worldspawn
mv_wsfile vmap
fi

printf "Built the editor successfully.\nInsert './worldspawn' to run.\n"
