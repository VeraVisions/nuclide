#
# Nuclide GNUMakefile
#
# Apr 2024 by Marco Cawthorne <marco@vera-visions.com>
# Last updated: 2025/01/30
#

# set `GAME` when issuing make. E.g. `make GAME=wastes`
GAME=base

# affects the output binary name (e.g. NAME=TheWastes > TheWastes_x64.exe) for dev builds
NAME=`./Tools/get-name.sh $(GAME)`
GAME_ARCH=x64
GAME_EXT=
GAME_BINARY=$(NAME)_$(GAME_ARCH)$(GAME_EXT)
GAMEDS_BINARY=$(NAME)DS_$(GAME_ARCH)$(GAME_EXT)

ENGINE_URL=https://www.github.com/fte-team/fteqw

# FTE specific builds
ENGINE_ARCH=amd64
ENGINE_CLBUILD=m-dbg
ENGINE_SVBUILD=sv-dbg
ENGINE_BINARY=./ThirdParty/fteqw/engine/debug/$(GAME)
ENGINE_DEDICATED=./ThirdParty/fteqw/engine/debug/$(GAME)-sv
ENGINE_BINARY_LIN32=./ThirdParty/fteqw/engine/release/$(GAME)32
ENGINE_BINARY_LIN64=./ThirdParty/fteqw/engine/release/$(GAME)64
ENGINE_BINARY_WIN32=./ThirdParty/fteqw/engine/release/$(GAME).exe
ENGINE_BINARY_WIN64=./ThirdParty/fteqw/engine/release/$(GAME)64.exe
ENGINE_DS_LIN32=./ThirdParty/fteqw/engine/release/$(GAME)-sv32
ENGINE_DS_LIN64=./ThirdParty/fteqw/engine/release/$(GAME)-sv64
ENGINE_DS_WIN32=./ThirdParty/fteqw/engine/release/$(GAME)sv.exe
ENGINE_DS_WIN64=./ThirdParty/fteqw/engine/release/$(GAME)sv64.exe

NUCLIDE_DIR=`pwd`
QCC_DIR=$(NUCLIDE_DIR)
BUILD_DIR=$(NUCLIDE_DIR)/build
EDITOR=radiant
NATIVE_PLUGINS=`head -n 1 ../../../$(GAME)/PLUGINS`
DEPENDS=`head -n 1 $(GAME)/DEPENDS`

define CMDSTR
#
endef

define ARGSTR
\$
endef

RADIANT_GAME="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/games/$(GAME).game"
RADIANT_XLINK="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game/game.xlink"
RADIANT_SYNAPSE="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game/synapse.config"
RADIANT_PROJECT="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/scripts/default_project.proj"
RADIANT_TEXTURES="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/textures"
RADIANT_DEF="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/scripts/entities.def"
RADIANT_SHADERLIST="$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/scripts/shaderlist.txt"

NR_GAMES="$(NUCLIDE_DIR)/ThirdParty/netradiant/build/gamepacks/games"
NR_GAME="$(NR_GAMES)/$(NAME).game"
NR_GAMEDIR="$(NUCLIDE_DIR)/ThirdParty/netradiant/build/gamepacks/$(NAME).game/$(GAME)/"
NR_DEF="$(NR_GAMEDIR)/entities.def"
NR_SYNAPSE="$(NR_GAMEDIR)/../default_build_menu.xml"

NRC_GAMES="$(NUCLIDE_DIR)/ThirdParty/netradiant-custom/install/gamepacks/games"
NRC_GAME="$(NRC_GAMES)/$(NAME).game"
NRC_GAMEDIR="$(NUCLIDE_DIR)/ThirdParty/netradiant-custom/install/gamepacks/$(NAME).game/$(GAME)/"
NRC_DEF="$(NRC_GAMEDIR)/entities.def"
NRC_SYNAPSE="$(NRC_GAMEDIR)/../default_build_menu.xml"

EDITOR_VMAP="$(ARGSTR)TEMPLATEenginepath/vmap"
EDITOR_ENGINEPATH="$(ARGSTR)TEMPLATEenginepath"
EDITOR_BASEPATH="$(ARGSTR)TEMPLATEbasedir"
EDITOR_HOMEPATH="$(ARGSTR)TEMPLATEuserhomepath"

help:
	@printf "################################################################################\n"
	@printf "   Nuclide Makefile Help            -           Developed by Vera Visions LLC\n"
	@printf "################################################################################\n"
	@printf "\nSwitch games by setting GAME=gamedir after the target\n\n"
	@printf "main targets:\n"
	@printf "\tgame \t\t\t\t# Builds the game logic\n"
	@printf "\t\t\t\t\t# alternatively: client, server, menu\n\n"
	@printf "\tdefs \t\t\t\t# Editor definitions\n"
	@printf "\tdefs-wad \t\t\t# WAD favoring editor definitions\n"
	@printf "\tengine [NAME=MyGame] \t\t# Branded engine binary\n"
	@printf "\tdedicated \t\t\t# Branded dedicated server binary\n"
	@printf "\tplugins \t\t\t# Plugins required by game\n"
	@printf "\ttools \t\t\t\t# Builds the various tools\n"
	@printf "\tfteqw \t\t\t\t# Builds FTEQW\n"
	@printf "\tfteqw \t\t\t\t# Builds FTEQCC\n"
	@printf "\tradiant \t\t\t# Builds GtkRadiant\n"
	@printf "\tnetradiant-custom \t\t# Builds NetRadiant-Custom\n"
	@printf "\tdocs \t\t\t\t# Builds Documentation/html/*.html\n"
	@printf "\tdist \t\t\t\t# Builds binary for distribution\n"
	@printf "\tclean[-game,engine,tools] \t# Cleans temp files\n"
	@printf "\tupdate \t\t\t\t# Update online repos.\n"

all: game engine dedicated plugins

game: fteqcc
	-cp src/cvar_defaults.cfg "$(GAME)/default_cvar.cfg"
	if [ -f "$(NUCLIDE_DIR)/$(GAME)/DEPENDS" ];then $(MAKE) game GAME=$(DEPENDS);fi
	cd "$(GAME)/src/" && $(MAKE) QCC=$(QCC_DIR)/../../fteqcc

client: fteqcc
	cd "$(GAME)/src/client/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc CFLAGS="-I$(QCC_DIR)/../../../src/common/"

server: fteqcc
	cd "$(GAME)/src/server/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc CFLAGS="-I$(QCC_DIR)/../../../src/common/"

rules: fteqcc
	cd "$(GAME)/src/rules/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc CFLAGS="-I$(QCC_DIR)/../../../src/common/"

menu: fteqcc
	cd "$(GAME)/src/menu/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc CFLAGS="-I$(QCC_DIR)/../../../src/common/"

mapc: fteqcc
	cd "$(GAME)/src/maps/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc CFLAGS="-I$(QCC_DIR)/../../../src/common/"

# will build a gamepack for gtkradiant
defs-nr-q3: netradiant trshaders $(GAME)/scripts/entities.def
	mkdir -p "$(NR_GAMEDIR)"
	mkdir -p "$(NR_GAMES)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(NR_GAME)"
	echo "<game" >> "$(NR_GAME)"
	echo "  type=\"q3\"" >> "$(NR_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(NR_GAME)"
	echo "  enginepath_linux=\"$(NUCLIDE_DIR)\"" >> "$(NR_GAME)"
	echo "  enginepath_win32=\"c:$(NUCLIDE_DIR)\"" >> "$(NR_GAME)"
	echo "  engine_win32=\"fteqw.exe\"" >> "$(NR_GAME)"
	echo "  engine_linux=\"fteqw\"" >> "$(NR_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(NR_GAME)"
	echo "  basegamename=\"$(NAME)\"" >> "$(NR_GAME)"
	echo "  unknowngamename=\"Custom Game Directory\"" >> "$(NR_GAME)"
	echo "  default_scale=\"1.0\"" >> "$(NR_GAME)"
	echo "  no_patch=\"1\"" >> "$(NR_GAME)"
	echo "  no_bsp_monitor=\"1\"" >> "$(NR_GAME)"
	echo "  archivetypes=\"pk3\"" >> "$(NR_GAME)"
	echo "  texturetypes=\"tga jpg png ktx dds\"" >> "$(NR_GAME)"
	echo "  modeltypes=\"md3 ase lwo obj 3ds 3d 3mf ac ac3d acc amf ask assbin b3d blend bvh cob csm dae dxf enff fbx glb gltf hmp iqm irr irrmesh lws lxo m3d md2 md5mesh mdc mdl mesh mesh.xml mot ms3d ndo nff off ply pmx prj q3o q3s raw scn sib smd stl ter uc vta x x3d x3db xgl xml zae zgl\"" >> "$(NR_GAME)"
	echo "  maptypes=\"mapq3\"" >> "$(NR_GAME)"
	echo "  shaders=\"quake3\"" >> "$(NR_GAME)"
	echo "  shaderpath=\"texturesrc\"" >> "$(NR_GAME)"
	echo "  entityclass=\"quake3\"" >> "$(NR_GAME)"
	echo "  entityclasstype=\"def xml\"" >> "$(NR_GAME)"
	echo "  entities=\"quake3\"" >> "$(NR_GAME)"
	echo "  brushtypes=\"quake3\"" >> "$(NR_GAME)"
	echo "  patchtypes=\"quake3\"" >> "$(NR_GAME)"
	echo "/>" >> "$(NR_GAME)"
	cp "$(GAME)/scripts/entities.def" "$(NR_DEF)"
	echo "<?xml version=\"1.0\"?>" > $(NR_SYNAPSE)
	echo "<project version=\"2.0\">" >> $(NR_SYNAPSE)
	echo "  <var name=\"vmap\">\"[EnginePath]vmap\"</var>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp -onlyents\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -onlyents \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis -fast\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>  </build>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "</project>" >> $(NR_SYNAPSE)

defs-nr-q1: netradiant $(GAME)/scripts/entities.def
	mkdir -p "$(NR_GAMEDIR)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(NR_GAME)"
	echo "<game" >> "$(NR_GAME)"
	echo "  type=\"q1\"" >> "$(NR_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(NR_GAME)"
	echo "  enginepath_linux=\"c:$(NUCLIDE_DIR)\"" >> "$(NR_GAME)"
	echo "  enginepath_win32=\"c:$(NUCLIDE_DIR)\"" >> "$(NR_GAME)"
	echo "  engine_win32=\"fteqw.exe\"" >> "$(NR_GAME)"
	echo "  engine_linux=\"fteqw\"" >> "$(NR_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(NR_GAME)"
	echo "  basegamename=\"$(NAME)\"" >> "$(NR_GAME)"
	echo "  unknowngamename=\"Custom Quake modification\"" >> "$(NR_GAME)"
	echo "  default_scale=\"1.0\"" >> "$(NR_GAME)"
	echo "  no_patch=\"1\"" >> "$(NR_GAME)"
	echo "  no_bsp_monitor=\"1\"" >> "$(NR_GAME)"
	echo "  show_wads=\"1\"" >> "$(NR_GAME)"
	echo "  archivetypes=\"pak wad\"" >> "$(NR_GAME)"
	echo "  texturetypes=\"tga jpg mip hlw\"" >> "$(NR_GAME)"
	echo "  modeltypes=\"mdl\"" >> "$(NR_GAME)"
	echo "  maptypes=\"mapq1\"" >> "$(NR_GAME)"
	echo "  shaders=\"quake3\"" >> "$(NR_GAME)"
	echo "  entityclass=\"quake3\"" >> "$(NR_GAME)"
	echo "  entityclasstype=\"def xml\"" >> "$(NR_GAME)"
	echo "  entities=\"quake3\"" >> "$(NR_GAME)"
	echo "  brushtypes=\"quake\"" >> "$(NR_GAME)"
	echo "  patchtypes=\"quake3\"" >> "$(NR_GAME)"
	echo "/>" >> "$(NR_GAME)"
	cp "$(GAME)/scripts/entities.def" "$(NR_DEF)"
	echo "<?xml version=\"1.0\"?>" > $(NR_SYNAPSE)
	echo "<project version=\"2.0\">" >> $(NR_SYNAPSE)
	echo "  <var name=\"bsp\">\"[EnginePath]qbsp\"</var>" >> $(NR_SYNAPSE)
	echo "  <var name=\"vis\">\"[EnginePath]qvis\"</var>" >> $(NR_SYNAPSE)
	echo "  <var name=\"light\">\"[EnginePath]qrad\"</var>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp -onlyents\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] -onlyents \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis -fast\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis -noambient\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qvis -noambient -fast\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad -extra\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad -extra4x4\">" >> $(NR_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NR_SYNAPSE)
	echo "  </build>" >> $(NR_SYNAPSE)
	echo "</project>" >> $(NR_SYNAPSE)

# will build a gamepack for gtkradiant
defs-nrc-q3: netradiant-custom trshaders $(GAME)/scripts/entities.def
	mkdir -p "$(NRC_GAMEDIR)"
	mkdir -p "$(NRC_GAMES)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(NRC_GAME)"
	echo "<game" >> "$(NRC_GAME)"
	echo "  type=\"q3\"" >> "$(NRC_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(NRC_GAME)"
	echo "  enginepath_linux=\"$(NUCLIDE_DIR)\"" >> "$(NRC_GAME)"
	echo "  enginepath_win32=\"c:$(NUCLIDE_DIR)\"" >> "$(NRC_GAME)"
	echo "  engine_win32=\"fteqw.exe\"" >> "$(NRC_GAME)"
	echo "  engine_linux=\"fteqw\"" >> "$(NRC_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(NRC_GAME)"
	echo "  basegamename=\"$(NAME)\"" >> "$(NRC_GAME)"
	echo "  unknowngamename=\"Custom Game Directory\"" >> "$(NRC_GAME)"
	echo "  default_scale=\"1.0\"" >> "$(NRC_GAME)"
	echo "  no_patch=\"1\"" >> "$(NRC_GAME)"
	echo "  no_bsp_monitor=\"1\"" >> "$(NRC_GAME)"
	echo "  archivetypes=\"pk3\"" >> "$(NRC_GAME)"
	echo "  texturetypes=\"tga jpg png ktx dds\"" >> "$(NRC_GAME)"
	echo "  modeltypes=\"md3 ase lwo obj 3ds 3d 3mf ac ac3d acc amf ask assbin b3d blend bvh cob csm dae dxf enff fbx glb gltf hmp iqm irr irrmesh lws lxo m3d md2 md5mesh mdc mdl mesh mesh.xml mot ms3d ndo nff off ply pmx prj q3o q3s raw scn sib smd stl ter uc vta x x3d x3db xgl xml zae zgl\"" >> "$(NRC_GAME)"
	echo "  maptypes=\"mapq3\"" >> "$(NRC_GAME)"
	echo "  shaders=\"quake3\"" >> "$(NRC_GAME)"
	echo "  shaderpath=\"texturesrc\"" >> "$(NRC_GAME)"
	echo "  entityclass=\"quake3\"" >> "$(NRC_GAME)"
	echo "  entityclasstype=\"def xml\"" >> "$(NRC_GAME)"
	echo "  entities=\"quake3\"" >> "$(NRC_GAME)"
	echo "  brushtypes=\"quake3\"" >> "$(NRC_GAME)"
	echo "  patchtypes=\"quake3\"" >> "$(NRC_GAME)"
	echo "/>" >> "$(NRC_GAME)"
	cp "$(GAME)/scripts/entities.def" "$(NRC_DEF)"
	echo "<?xml version=\"1.0\"?>" > $(NRC_SYNAPSE)
	echo "<project version=\"2.0\">" >> $(NRC_SYNAPSE)
	echo "  <var name=\"vmap\">\"[EnginePath]vmap\"</var>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp -onlyents\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -onlyents \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis -fast\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -vis \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vmap] -fs_basepath \"[EnginePath]\" -fs_game \"[GameName]\" -light \"[MapFile]\"</command>  </build>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "</project>" >> $(NRC_SYNAPSE)

defs-nrc-q1: netradiant-custom $(GAME)/scripts/entities.def
	mkdir -p "$(NRC_GAMEDIR)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(NRC_GAME)"
	echo "<game" >> "$(NRC_GAME)"
	echo "  type=\"q1\"" >> "$(NRC_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(NRC_GAME)"
	echo "  enginepath_linux=\"c:$(NUCLIDE_DIR)\"" >> "$(NRC_GAME)"
	echo "  enginepath_win32=\"c:$(NUCLIDE_DIR)\"" >> "$(NRC_GAME)"
	echo "  engine_win32=\"fteqw.exe\"" >> "$(NRC_GAME)"
	echo "  engine_linux=\"fteqw\"" >> "$(NRC_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(NRC_GAME)"
	echo "  basegamename=\"$(NAME)\"" >> "$(NRC_GAME)"
	echo "  unknowngamename=\"Custom Quake modification\"" >> "$(NRC_GAME)"
	echo "  default_scale=\"1.0\"" >> "$(NRC_GAME)"
	echo "  no_patch=\"1\"" >> "$(NRC_GAME)"
	echo "  no_bsp_monitor=\"1\"" >> "$(NRC_GAME)"
	echo "  show_wads=\"1\"" >> "$(NRC_GAME)"
	echo "  archivetypes=\"pak wad\"" >> "$(NRC_GAME)"
	echo "  texturetypes=\"tga jpg mip hlw\"" >> "$(NRC_GAME)"
	echo "  modeltypes=\"mdl\"" >> "$(NRC_GAME)"
	echo "  maptypes=\"mapq1\"" >> "$(NRC_GAME)"
	echo "  shaders=\"quake3\"" >> "$(NRC_GAME)"
	echo "  entityclass=\"quake3\"" >> "$(NRC_GAME)"
	echo "  entityclasstype=\"def xml\"" >> "$(NRC_GAME)"
	echo "  entities=\"quake3\"" >> "$(NRC_GAME)"
	echo "  brushtypes=\"quake\"" >> "$(NRC_GAME)"
	echo "  patchtypes=\"quake3\"" >> "$(NRC_GAME)"
	echo "/>" >> "$(NRC_GAME)"
	cp "$(GAME)/scripts/entities.def" "$(NRC_DEF)"
	echo "<?xml version=\"1.0\"?>" > $(NRC_SYNAPSE)
	echo "<project version=\"2.0\">" >> $(NRC_SYNAPSE)
	echo "  <var name=\"bsp\">\"[EnginePath]qbsp\"</var>" >> $(NRC_SYNAPSE)
	echo "  <var name=\"vis\">\"[EnginePath]qvis\"</var>" >> $(NRC_SYNAPSE)
	echo "  <var name=\"light\">\"[EnginePath]qrad\"</var>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp -onlyents\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] -onlyents \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis -fast\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis -noambient\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qvis -noambient -fast\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis, qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -fast, qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient, qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] \"[MapFile]\"</command>  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad -extra\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "  <build name=\"qbsp, qvis -noambient -fast, qrad -extra4x4\">" >> $(NRC_SYNAPSE)
	echo "    <command>[bsp] \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[vis] -noambient -fast \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "    <command>[light] -extra4x4 \"[MapFile]\"</command>" >> $(NRC_SYNAPSE)
	echo "  </build>" >> $(NRC_SYNAPSE)
	echo "</project>" >> $(NRC_SYNAPSE)

# will build a gamepack for gtkradiant
defs-gtkradiant-q3: radiant trshaders $(GAME)/scripts/entities.def
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(RADIANT_GAME)"
	echo "<game" >> "$(RADIANT_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(RADIANT_GAME)"
	echo "  enginepath_linux=\"$(NUCLIDE_DIR)\"" >> "$(RADIANT_GAME)"
	echo "  gametools_linux=\"$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game\"" >> "$(RADIANT_GAME)"
	echo "  prefix=\".$(GAME)\"" >> "$(RADIANT_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(RADIANT_GAME)"
	echo "/>" >> "$(RADIANT_GAME)"
	mkdir -p "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(RADIANT_XLINK)"
	echo "<!-- Links for the $(NAME) game pack -->" >> "$(RADIANT_XLINK)"
	echo "<links>" >> "$(RADIANT_XLINK)"
	echo "<item name=\"Nuclide Developer Reference\" url=\"http://developer.vera-visions.com/\"/>" >> "$(RADIANT_XLINK)"
	echo "<item name=\"Vera Visions\" url=\"http://www.vera-visions.com/\"/>" >> "$(RADIANT_XLINK)"
	echo "</links>" >> "$(RADIANT_XLINK)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?><synapseconfig><client name=\"core\"><api name=\"image\">" > "$(RADIANT_SYNAPSE)"
	echo "png jpg tga" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "pk3" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"map\">" >> "$(RADIANT_SYNAPSE)"
	echo "mapq3" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"eclass\">" >> "$(RADIANT_SYNAPSE)"
	echo "def" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"surfdialog\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"image\"><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "pk3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"shaders\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "pk3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"map\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"xmap\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"model\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "quake3" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "pk3" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client></synapseconfig>" >> "$(RADIANT_SYNAPSE)"
	mkdir -p "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/scripts"
	cp "$(GAME)/scripts/entities.def" "$(RADIANT_DEF)"
	echo "<?xml version=\"1.0\"?>" > "$(RADIANT_PROJECT)"
	echo "<!DOCTYPE project SYSTEM \"dtds/project.dtd\">" >> "$(RADIANT_PROJECT)"
	echo "<project>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"version\" value=\"2\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"template_version\" value=\"8\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"basepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"rshcmd\" value=\"\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"remotebasepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"entitypath\" value=\"$(ARGSTR)TEMPLATEtoolspath$(EDITOR_BASEPATH)/scripts/entities.def\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"texturepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/textures/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"autosave\" value=\"$(EDITOR_HOMEPATH)$(EDITOR_BASEPATH)/maps/autosave.map\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"mapspath\" value=\"$(EDITOR_HOMEPATH)$(EDITOR_BASEPATH)/maps/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Fast Fullbright)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt$(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Fast Light)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -light -custinfoparms -v -samplesize 8 -fast -threads 4 -samples 4 -shade -shadeangle 60 -patchshadows $(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Full)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -light -custinfoparms -samplesize 8 -fast -threads 4 -samples 4 -shade -shadeangle 60 -patchshadows $(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "</project>" >> "$(RADIANT_PROJECT)"
	echo "" > "$(RADIANT_SHADERLIST)"
	mkdir -p "$(RADIANT_TEXTURES)/."
	rsync -rva "$(NUCLIDE_DIR)/Tools/textures/." "$(RADIANT_TEXTURES)/."
	mkdir -p "$(HOME)/.$(GAME)/$(GAME)/scripts"

# will build a gamepack for gtkradiant
defs-gtkradiant-q1: radiant $(GAME)/scripts/entities.def
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(RADIANT_GAME)"
	echo "<game" >> "$(RADIANT_GAME)"
	echo "  name=\"$(NAME)\"" >> "$(RADIANT_GAME)"
	echo "  enginepath_linux=\"$(NUCLIDE_DIR)\"" >> "$(RADIANT_GAME)"
	echo "  gametools_linux=\"$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game\"" >> "$(RADIANT_GAME)"
	echo "  prefix=\".$(GAME)\"" >> "$(RADIANT_GAME)"
	echo "  basegame=\"$(GAME)\"" >> "$(RADIANT_GAME)"
	echo "/>" >> "$(RADIANT_GAME)"
	mkdir -p "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/game"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>" > "$(RADIANT_XLINK)"
	echo "<!-- Links for the $(NAME) game pack -->" >> "$(RADIANT_XLINK)"
	echo "<links>" >> "$(RADIANT_XLINK)"
	echo "<item name=\"Nuclide Developer Reference\" url=\"http://developer.vera-visions.com/\"/>" >> "$(RADIANT_XLINK)"
	echo "<item name=\"Vera Visions\" url=\"http://www.vera-visions.com/\"/>" >> "$(RADIANT_XLINK)"
	echo "</links>" >> "$(RADIANT_XLINK)"
	echo "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?><synapseconfig><client name=\"core\"><api name=\"image\">" > "$(RADIANT_SYNAPSE)"
	echo "pcx tga mip" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "wad" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"map\">" >> "$(RADIANT_SYNAPSE)"
	echo "maphl" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"eclass\">" >> "$(RADIANT_SYNAPSE)"
	echo "def" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"surfdialog\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"image\"><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "wad" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"shaders\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "wad" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"map\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"xmap\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client><client name=\"model\"><api name=\"shaders\">" >> "$(RADIANT_SYNAPSE)"
	echo "idtech2" >> "$(RADIANT_SYNAPSE)"
	echo "</api><api name=\"VFS\">" >> "$(RADIANT_SYNAPSE)"
	echo "wad" >> "$(RADIANT_SYNAPSE)"
	echo "</api></client></synapseconfig>" >> "$(RADIANT_SYNAPSE)"
	mkdir -p "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/scripts"
	cp "$(GAME)/scripts/entities.def" "$(RADIANT_DEF)"
	echo "<?xml version=\"1.0\"?>" > "$(RADIANT_PROJECT)"
	echo "<!DOCTYPE project SYSTEM \"dtds/project.dtd\">" >> "$(RADIANT_PROJECT)"
	echo "<project>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"version\" value=\"2\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"template_version\" value=\"8\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"basepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"rshcmd\" value=\"\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"remotebasepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"entitypath\" value=\"$(ARGSTR)TEMPLATEtoolspath$(EDITOR_BASEPATH)/scripts/entities.def\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"texturepath\" value=\"$(EDITOR_ENGINEPATH)$(EDITOR_BASEPATH)/textures/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"autosave\" value=\"$(EDITOR_HOMEPATH)$(EDITOR_BASEPATH)/maps/autosave.map\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"mapspath\" value=\"$(EDITOR_HOMEPATH)$(EDITOR_BASEPATH)/maps/\"/>" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Fast Fullbright)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt$(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Fast Light)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -light -custinfoparms -v -samplesize 8 -fast -threads 4 -samples 4 -shade -shadeangle 60 -patchshadows $(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "<key name=\"bsp_VMAP: (Full)\" value=\"! &quot;$(EDITOR_VMAP)&quot; -v $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -custinfoparms -threads 4 -samplesize 8 $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -vis -saveprt $(ARGSTR) &amp;&amp; ! &quot;$(EDITOR_VMAP)&quot; $(CMDSTR) -game $(GAME) -fs_basepath &quot;$(EDITOR_ENGINEPATH)&quot; -light -custinfoparms -samplesize 8 -fast -threads 4 -samples 4 -shade -shadeangle 60 -patchshadows $(ARGSTR)\" />" >> "$(RADIANT_PROJECT)"
	echo "</project>" >> "$(RADIANT_PROJECT)"
	mkdir -p "$(RADIANT_TEXTURES)/."
	mkdir -p "$(HOME)/.$(GAME)/$(GAME)/scripts"
	rsync -rva "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/." "$(HOME)/.$(GAME)/$(GAME)/."
	rsync -rva "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/install/installs/$(NAME)Pack/install/$(GAME)/." "./$(GAME)/."

defs:
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/build/plugins" ];then $(MAKE) defs-gtkradiant-q3;fi
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/netradiant/build/plugins" ];then $(MAKE) defs-nr-q3;fi
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/netradiant-custom/install/plugins" ];then $(MAKE) defs-nrc-q3;fi

defs-wad:
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/gtkradiant/build/plugins" ];then $(MAKE) defs-gtkradiant-q1;fi
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/netradiant/build/plugins" ];then $(MAKE) defs-nr-q1;fi
	if [ -d "$(NUCLIDE_DIR)/ThirdParty/netradiant-custom/install/plugins" ];then $(MAKE) defs-nrc-q1;fi

$(GAME)/scripts/entities.def:
	Tools/make_mapdef.sh $(GAME)
	
maps:
	Tools/make_maps.sh $(GAME)

wads: imgtool
	./Tools/build_wads.sh $(GAME)
	
textures:
	Tools/make_textures.sh $(GAME)
	
$(GAME)/maps/%.bsp:
	Tools/make_map.sh $(GAME) "$@"
	
models:
	Tools/make_models.sh $(GAME)

docs:
	doxygen

# devel
engine:	$(ENGINE_BINARY)
dedicated:	$(ENGINE_DEDICATED)
plugins:	fteqw-plugins
editor:	$(EDITOR)

# release
engine-win32: $(ENGINE_BINARY_WIN32)
engine-win64: $(ENGINE_BINARY_WIN64)
engine-lin32: $(ENGINE_BINARY_LIN32)
engine-lin64: $(ENGINE_BINARY_LIN64)

dedicated-win32: $(ENGINE_DS_WIN32)
dedicated-win64: $(ENGINE_DS_WIN64)
dedicated-lin32: $(ENGINE_DS_LIN32)
dedicated-lin64: $(ENGINE_DS_LIN64)

# misc
tools: fteqcc vmap vvmtool iqmtool imgtool generatebuiltinsl makevulkanblob

vmap:
	if [ ! -d Tools/vmap ];then git clone https://github.com/VeraVisions/vmap Tools/vmap;else cd ./Tools/vmap && git pull;fi
	cd Tools/vmap && $(MAKE)
	-install -m 0777 Tools/vmap/vmap vmap

vvmtool:
	if [ ! -d Tools/vvmtool ];then git clone https://github.com/VeraVisions/vvmtool Tools/vvmtool;else cd ./Tools/vvmtool && git pull;fi
	cd Tools/vvmtool && $(MAKE)
	-install -m 0777 Tools/vvmtool/vvmtool vvmtool

dist: dist-pak dist-engine

dist-engine: engine-lin32 engine-lin64 engine-win32 engine-win64 dedicated-lin32 dedicated-lin64 dedicated-win32 dedicated-win64

dist-pak: fteqcc
	if [ -d $(GAME)/src ];then $(MAKE) game GAME=$(GAME) NAME="$(NAME)";fi
	mkdir -p "$(BUILD_DIR)/$(NAME)-content/$(GAME)"
	if [ -f $(GAME)/DEPENDS ];then ./Tools/make_dist.sh "$(DEPENDS)" $(BUILD_DIR)/$(NAME)-content/$(GAME) >> $(BUILD_DIR)/$(NAME)-content.log;fi
	./Tools/make_dist.sh "$(GAME)" $(BUILD_DIR)/$(NAME)-content/$(GAME) >> $(BUILD_DIR)/$(NAME)-content.log
	-$(GAME)/post-dist.sh "$(GAME)" "$(BUILD_DIR)/$(NAME)-content"
	@printf "Building finished. Check %s\n", "$(BUILD_DIR)/$(NAME)-content"

# generate trinity .shader files from .mat within the game directory
trshaders:
	Tools/make_trshaders.sh $(GAME)

# recycling center
vacuum:
	-rm ./$(GAME)/csqccore.txt
	-rm ./$(GAME)/ssqccore.txt
	-rm ./$(GAME)/menucore.txt
	-rm ./$(GAME)/condump.txt
	-rm ./$(GAME)/fte.cfg
	-rm ./$(GAME)/config.cfg
	-rm ./$(GAME)/*.lno
	-rm -rfv ./$(GAME)/csprogsvers
	-rm -rfv ./$(GAME)/saves

clean: clean-game clean-engine clean-tools clean-dist

clean-dist:
	-rm -r $(BUILD_DIR)/$(NAME)-content/
	-rm -r $(BUILD_DIR)/$(NAME)-win/
	-rm -r $(BUILD_DIR)/$(NAME)-linux/

clean-game:
	-rm conhistory.txt crash.log fullchain.pem \
	  privkey.pem installed.lst $(GAME)/csprogs.dat \
	  $(GAME)/menu.dat $(GAME)/progs.dat $(GAME)/csprogs.lno \
	  $(GAME)/menu.lno $(GAME)/progs.lno $(GAME)/csqccore.txt \
	  $(GAME)/menucore.txt $(GAME)/ssqccore.txt

clean-engine:
	cd ThirdParty/fteqw/engine && $(MAKE) clean
	-rm $(NAME)_x64$(GAME_EXT) $(NAME)_x86$(GAME_EXT) $(NAME)DS_x64$(GAME_EXT) $(NAME)DS_x86$(GAME_EXT)

clean-fteqw:
	cd ThirdParty/fteqw/engine && $(MAKE) clean
	-rm fteqw fteqw-sv

clean-tools:
	cd Tools/vmap && $(MAKE) clean
	cd Tools/vvmtool && $(MAKE) clean
	cd ThirdParty/fteqw/engine && $(MAKE) clean
	-rm vmap vvmtool iqmtool imgtool fteqcc generatebuiltinsl makevulkanblob

debug: $(ENGINE_BINARY)
	gdb --args ./$(GAME_BINARY) +set sv_cheats 1 +set sv_csqcdebug 1 +set g_logLevel 3 +set g_logTimestamps 1

update:
	if [ -f ./.git/config ];then git pull;fi
	if [ -f $(GAME)/.git/config ];then cd $(GAME) && git pull;fi
	if [ ! -d ThirdParty/fteqw ];then git clone $(ENGINE_URL) ThirdParty/fteqw;else cd ./ThirdParty/fteqw && git pull;fi
	if [ ! -d Tools/vvmtool ];then git clone https://github.com/VeraVisions/vvmtool Tools/vvmtool;else cd ./Tools/vvmtool && git pull;fi
	if [ ! -d Tools/vmap ];then git clone https://github.com/VeraVisions/vmap Tools/vmap;else cd ./Tools/vmap && git pull;fi
	if [ ! -d ThirdParty/gtkradiant ];then git clone https://github.com/TTimo/gtkradiant ThirdParty/gtkradiant;else cd ./ThirdParty/gtkradiant && git pull;fi
	if [ ! -d ThirdParty/netradiant-custom ];then git clone https://github.com/Garux/netradiant-custom ThirdParty/netradiant-custom;else cd ./ThirdParty/netradiant-custom && git pull;fi

# game engine binaries

$(ENGINE_BINARY):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	-cp $(GAME)/icon.ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	-cp $(GAME)/$(GAME).ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	cd ThirdParty/fteqw/engine && $(MAKE) $(ENGINE_CLBUILD) PKGCONFIG=pkg-config FTE_CONFIG=$(GAME) ARCH=x86_64
	-install -m 0777 $(ENGINE_BINARY) ./$(GAME_BINARY)

$(ENGINE_BINARY_WIN32): 
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	-cp $(GAME)/icon.ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	-cp $(GAME)/$(GAME).ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	-install -m 0777 $(ENGINE_BINARY_WIN32) $(BUILD_DIR)/$(NAME)-win/$(NAME)_x86.exe
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-rel NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_CONFIG=$(GAME) FTE_TARGET=win32
	find ThirdParty/fteqw/engine/release/ -name "fteplug_*.dll" -exec mv '{}' $(BUILD_DIR)/$(NAME)-win/ \;

$(ENGINE_BINARY_WIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	-cp $(GAME)/icon.ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	-cp $(GAME)/$(GAME).ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	-install -m 0777 $(ENGINE_BINARY_WIN64) $(BUILD_DIR)/$(NAME)-win/$(NAME)_x64.exe
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-rel NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_CONFIG=$(GAME) FTE_TARGET=win64
	find ThirdParty/fteqw/engine/release/ -name "fteplug_*.dll" -exec mv '{}' $(BUILD_DIR)/$(NAME)-win/ \;

$(ENGINE_BINARY_LIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=i686 FTE_TARGET=linux32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	-cp $(GAME)/icon.ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	-cp $(GAME)/$(GAME).ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel ARCH=i686 FTE_TARGET=linux32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-rel NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_CONFIG=$(GAME) FTE_TARGET=linux32
	find ThirdParty/fteqw/engine/release/ -name "fteplug_*.so" -exec mv '{}' $(BUILD_DIR)/$(NAME)-linux/ \;
	-install -m 0777 $(ENGINE_BINARY_LIN32) $(BUILD_DIR)/$(NAME)-linux/$(NAME)_x86

$(ENGINE_BINARY_LIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64 FTE_TARGET=linux64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	-cp $(GAME)/icon.ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	-cp $(GAME)/$(GAME).ico ./ThirdParty/fteqw/engine/common/$(GAME).ico
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel ARCH=x86_64 FTE_TARGET=linux64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	-install -m 0777 $(ENGINE_BINARY_LIN64) $(BUILD_DIR)/$(NAME)-linux/$(NAME)_x64
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-rel NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_CONFIG=$(GAME) FTE_TARGET=linux64
	find ThirdParty/fteqw/engine/release/ -name "fteplug_*.so" -exec mv '{}' $(BUILD_DIR)/$(NAME)-linux/ \;

# game dedicated binaries

$(ENGINE_DEDICATED):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-dbg FTE_CONFIG=$(GAME) ARCH=x86_64
	-install -m 0777 $(ENGINE_DEDICATED) ./$(GAMEDS_BINARY)

$(ENGINE_DS_LIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel FTE_TARGET=win32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	-install -m 0777 $(ENGINE_DS_WIN32) $(BUILD_DIR)/$(NAME)-win/$(NAME)DS_x86.exe

$(ENGINE_DS_LIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel FTE_TARGET=win64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	-install -m 0777 $(ENGINE_DS_WIN64) $(BUILD_DIR)/$(NAME)-win/$(NAME)DS_x64.exe

$(ENGINE_DS_WIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=i686 FTE_TARGET=linux32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel ARCH=i686 FTE_TARGET=linux32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	-install -m 0777 $(ENGINE_DS_LIN32) $(BUILD_DIR)/$(NAME)-linux/$(NAME)DS_x86

$(ENGINE_DS_WIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64 FTE_TARGET=linux64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel ARCH=x86_64 FTE_TARGET=linux64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	-install -m 0777 $(ENGINE_DS_LIN64) $(BUILD_DIR)/$(NAME)-linux/$(NAME)DS_x64

# tools

iqmtool:
	cd ThirdParty/fteqw/engine && $(MAKE) iqmtool
	-install -m 0777 ./ThirdParty/fteqw/engine/release/iqmtool ./

imgtool:
	cd ThirdParty/fteqw/engine && $(MAKE) imgtool CFLAGS="-g -DFTE_SDL -I/usr/include/SDL2" LDFLAGS="-lSDL2"
	-install -m 0777 ./ThirdParty/fteqw/engine/release/imgtool ./

fteqcc:
	if [ ! -d ThirdParty ];then mkdir ThirdParty && git clone $(ENGINE_URL) ThirdParty/fteqw;fi
	cd ThirdParty/fteqw/engine && $(MAKE) qcc-rel
	-install -m 0777 ./ThirdParty/fteqw/engine/release/fteqcc ./

generatebuiltinsl:
	cd ThirdParty/fteqw/engine/shaders && $(MAKE) generatebuiltinsl
	-install -m 0777 ./ThirdParty/fteqw/engine/shaders/generatebuiltinsl ./

makevulkanblob:
	cd ThirdParty/fteqw/engine/shaders && $(MAKE) makevulkanblob
	-install -m 0777 ./ThirdParty/fteqw/engine/shaders/makevulkanblob ./

# stock FTE engine
fteqw:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cd ThirdParty/fteqw/engine && $(MAKE) $(ENGINE_CLBUILD) PKGCONFIG=pkg-config ARCH=x86_64
	-install -m 0777 ./ThirdParty/fteqw/engine/debug/fteqw ./

fteqwglqw64.exe:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win64
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	-install -m 0777 $(ENGINE_BINARY_WIN64) $(BUILD_DIR)/fteqwglqw64.exe

fteqw-sv:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cd ThirdParty/fteqw/engine && $(MAKE) sv-dbg FTE_CONFIG=fteqw ARCH=x86_64
	-install -m 0777 ./ThirdParty/fteqw/engine/debug/fteqw-sv ./fteqw-sv

# stock FTE plugins
fteqw-plugins:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS="$(NATIVE_PLUGINS)"
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.so" -exec mv '{}' ./ \;

fteqw-plugins-win32:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_TARGET=win32
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-win64:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_TARGET=win64
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-lin32:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_TARGET=linux32
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-lin64:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS="$(NATIVE_PLUGINS)" FTE_TARGET=linux64
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

# level editing software
radiant:
	if [ ! -d ThirdParty/gtkradiant ];then git clone https://github.com/TTimo/gtkradiant ThirdParty/gtkradiant;fi
	cd ThirdParty/gtkradiant && scons --no-packs
	Tools/make_launcher.sh ./ThirdParty/gtkradiant/install/ ./radiant.bin radiant

netradiant-custom:
	if [ ! -d ThirdParty/netradiant-custom ];then git clone https://github.com/Garux/netradiant-custom ThirdParty/netradiant-custom;fi
	cd ThirdParty/netradiant-custom && $(MAKE) DOWNLOAD_GAMEPACKS=no BUILD=debug RADIANT_ABOUTMSG="NuclideLite managed build."
	mkdir -p ./ThirdParty/netradiant-custom/install/gamepacks/games
	Tools/make_launcher.sh ./ThirdParty/netradiant-custom/install/ ./radiant.x86_64 netradiant-custom

# TODO: still needs a gamepack
netradiant:
	if [ ! -d ThirdParty/netradiant ];then git clone --recursive https://gitlab.com/xonotic/netradiant ThirdParty/netradiant;fi
	cd ThirdParty/netradiant && cmake -G "Unix Makefiles" -S. -Bbuild -DCMAKE_BUILD_TYPE=Debug -DCMAKE_MAKE_PROGRAM=$(MAKE) -DDOWNLOAD_GAMEPACKS=OFF
	cd ThirdParty/netradiant && cmake --build build -- -j$(nproc)
	cd ThirdParty/netradiant && cmake --install build
	Tools/make_launcher.sh ./ThirdParty/netradiant/build/ ./netradiant netradiant

