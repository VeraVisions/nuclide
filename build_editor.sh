#!/bin/sh

mv_wsfile()
{
	cp -v "./build/$1" "../../bin/$1"
}

set -e

WS_MAKEFILE=./src/worldspawn/CMakeLists.txt

mkdir -p ./bin

if [ -f "$WS_MAKEFILE" ]; then
	printf "WorldSpawn is present, updating...\n"
	cd ./src/worldspawn/
	git pull
else
	printf "WorldSpawn is NOT present, cloning...\n"
	cd ./src/
	git clone https://git.code.sf.net/p/worldspawn/code worldspawn
	cd ./worldspawn
fi

cmake -G "Unix Makefiles" -H. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build -- -j$(nproc)

mkdir -p ../../bin/bitmaps
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
mv_wsfile bitmaps/side_clipper.xpm
mv_wsfile bitmaps/side_edges.xpm
mv_wsfile bitmaps/side_entities.xpm
mv_wsfile bitmaps/side_faces.xpm
mv_wsfile bitmaps/side_find.xpm
mv_wsfile bitmaps/side_patch.xpm
mv_wsfile bitmaps/side_resize.xpm
mv_wsfile bitmaps/side_rotate.xpm
mv_wsfile bitmaps/side_scale.xpm
mv_wsfile bitmaps/side_surface.xpm
mv_wsfile bitmaps/side_textures.xpm
mv_wsfile bitmaps/side_transform.xpm
mv_wsfile bitmaps/side_vertices.xpm
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
mv_wsfile global.xlink
mkdir -p ../../bin/modules
mv_wsfile modules/libarchivezip.so
mv_wsfile modules/libentity.so
mv_wsfile modules/libimage.so
mv_wsfile modules/libiqmmodel.so
mv_wsfile modules/libmapq3.so
mv_wsfile modules/libmodel.so
mv_wsfile modules/libshaders.so
mv_wsfile modules/libvfspk3.so
mkdir -p ../../bin/plugins
mv_wsfile plugins/libbrushexport.so
mv_wsfile plugins/libprtview.so
mkdir -p ../../bin/platform.game
mv_wsfile platform.game/default_build_menu.xml
mkdir -p ../../bin/platform.game/platform
mv_wsfile platform.game/platform/entities.def
mv_wsfile WorldSpawn_MAJOR
mv_wsfile WorldSpawn_MINOR
mv_wsfile WorldSpawn_PATCH
mv_wsfile vmap
mv_wsfile worldspawn

cd ../../src
./mk_mapdef.sh
cp -v ./entities.def ../bin/platform.game/platform/entities.def
