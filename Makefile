#
# Nuclide Makefile
#
# Apr 2024 by Marco Cawthorne <marco@vera-visions.com>
#

# set `GAME` when issuing make. E.g. `make GAME=wastes`
GAME=base
# affects the output binary name (e.g. NAME=TheWastes > TheWastes_x64.exe)

GAME_ARCH=x64
GAME_EXT=
GAME_BINARY=$(NAME)_$(GAME_ARCH)$(GAME_EXT)
GAMEDS_BINARY=$(NAME)DS_$(GAME_ARCH)$(GAME_EXT)

# fte specific
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

NAME=`./Tools/get-name.sh $(GAME)`

NATIVE_PLUGINS="ffmpeg ode"

help:
	@printf "#####################\nNuclide Makefile Help\n#####################\n\nmain targets:\n"
	@printf "\tgame [GAME=base]\n"
	@printf "\t\talternatively: client, server, menu [GAME=base]\n"
	@printf "\tedef [GAME=base]\n"
	@printf "\tengine [GAME=base] [NAME=MyGame]\n"
	@printf "\tdedicated [GAME=base]\n"
	@printf "\tplugins [GAME=base] [NATIVE_PLUGINS=\"ode ffmpeg\"]\n"
	@printf "\ttools\n"
	@printf "\teditor\n"
	@printf "\tdocs\n"
	@printf "\tdist [GAME=base]\n"
	@printf "\tclean[-game,engine,tools] [GAME=base]\n"
	@printf "\tupdate [GAME=base]\n"
	@printf "\nthird-party targets:\n"
	@printf "\tfteqw, fteqw-sv, fteqw-plugins\n"
	@printf "\tradiant, netradiant-custom\n"

all: game engine dedicated fteqw-plugins

game: fteqcc
	cd "$(GAME)/src/" && $(MAKE) QCC=$(QCC_DIR)/../../fteqcc

client: fteqcc
	cd "$(GAME)/src/client/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc

server: fteqcc
	cd "$(GAME)/src/server/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc

menu: fteqcc
	cd "$(GAME)/src/menu/" && $(MAKE) QCC=$(QCC_DIR)/../../../fteqcc

edef:
	Tools/make_mapdef.sh $(GAME)
	#-mkdir -p "ThirdParty/gtkradiant/install/gamepacks/$(GAME).game/$(GAME)/"
	#-cp "$(GAME)/radiant.game" "ThirdParty/gtkradiant/install/games/$(GAME).game"
	#-cp "$(GAME)/entities.def" "ThirdParty/gtkradiant/install/gamepacks/$(GAME).game/$(GAME)/entities.def"
	#-cp "$(GAME)/radiant.xml" "ThirdParty/gtkradiant/install/gamepacks/$(GAME).game/default_build_menu.xml"
	#sed -i 's/enginepath_linux=\"\"/enginepath_linux=\"$(NUCLIDE_DIR)\"/g' "ThirdParty/gtkradiant/install/games/$(GAME).game"
	#-mkdir -p "ThirdParty/netradiant-custom/install/gamepacks/$(GAME).game/$(GAME)/"
	#-cp "$(GAME)/radiant.game" "ThirdParty/netradiant-custom/install/gamepacks/games/$(GAME).game"
	#-cp "$(GAME)/entities.def" "ThirdParty/netradiant-custom/install/gamepacks/$(GAME).game/$(GAME)/entities.def"
	#-cp "$(GAME)/radiant.xml" "ThirdParty/netradiant-custom/install/gamepacks/$(GAME).game/default_build_menu.xml"
	#sed -i 's/enginepath_linux=\"\"/enginepath_linux=\"$(NUCLIDE_DIR)\"/g' "ThirdParty/netradiant-custom/install/gamepacks/games/$(GAME).game"

docs:
	doxygen
	#printf "# Entity Guide\n\n# Overview\n\n" > ./Documentation/EntityGuide.md
	#cd ./src/gs-entbase && grep -r "QUAKED" | awk '{ print $2 }' | sort | uniq | awk '{ printf "[%s](@ref %s)\n\n", $1, $1; }'  >> ../../Documentation/EntityGuide.md

# devel
engine:	$(ENGINE_BINARY)
dedicated:	$(ENGINE_DEDICATED)
plugins:	fteqw-plugins
editor:	worldspawn

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
tools: fteqcc vmap vvmtool iqmtool imgtool

vmap:
	cd Tools/vmap && $(MAKE)
	install -m 0777 Tools/vmap/vmap vmap

vvmtool:
	cd Tools/vvmtool && $(MAKE)
	install -m 0777 Tools/vvmtool/vvmtool vvmtool

worldspawn:
	cd Tools/worldspawn && $(MAKE)

dist: dist-pak dist-engine

dist-engine: engine-lin32 engine-lin64 engine-win32 engine-win64 dedicated-lin32 dedicated-lin64 dedicated-win32 dedicated-win64

dist-pak:
	mkdir -p "$(BUILD_DIR)/$(NAME)-content/$(GAME)"
	./Tools/make_dist.sh "$(GAME)" $(BUILD_DIR)/$(NAME)-content/$(GAME)
	-$(GAME)/post-dist.sh "$(GAME)" "$(BUILD_DIR)/$(NAME)-content"

# generate trinity .shader files from .mat within the game directory
trshaders:
	Tools/make_trshaders.sh $(GAME)

# recycling center
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
	  $(GAME)/menucore.txt $(GAME)/ssqccore.txt fteplug_*.so

clean-engine:
	cd ThirdParty/fteqw/engine && $(MAKE) clean
	-rm $(NAME)_x64$(GAME_EXT) $(NAME)_x86$(GAME_EXT) $(NAME)DS_x64$(GAME_EXT) $(NAME)DS_x86$(GAME_EXT) fteqw fteqw-sv

clean-tools:
	cd Tools/vmap && $(MAKE) clean
	cd Tools/vvmtool && $(MAKE) clean
	cd ThirdParty/fteqw/engine && $(MAKE) clean
	-rm vmap vvmtool iqmtool imgtool fteqcc

update:
	if [ -f ./.git/config ];then git pull;fi
	if [ -f $(GAME)/.git/config ];then cd $(GAME) && git pull;fi
	if [ ! -d ThirdParty/fteqw ];then git clone https://www.github.com/fte-team/fteqw ThirdParty/fteqw;else cd ./ThirdParty/fteqw && git pull;fi
	if [ ! -d Tools/vvmtool ];then git clone https://github.com/VeraVisions/vvmtool Tools/vvmtool;else cd ./Tools/vvmtool && git pull;fi
	if [ ! -d Tools/vmap ];then git clone https://github.com/VeraVisions/vmap Tools/vmap;else cd ./Tools/vmap && git pull;fi
	if [ ! -d Tools/worldspawn ];then git clone https://github.com/VeraVisions/worldspawn Tools/worldspawn;else cd ./Tools/worldspawn && git pull;fi
	if [ ! -d ThirdParty/gtkradiant ];then git clone https://github.com/TTimo/gtkradiant ThirdParty/gtkradiant;else cd ./ThirdParty/gtkradiant && git pull;fi
	if [ ! -d ThirdParty/netradiant-custom ];then git clone https://github.com/Garux/netradiant-custom ThirdParty/netradiant-custom;else cd ./ThirdParty/netradiant-custom && git pull;fi

# fte specific corner
fteqw-plugins:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS=$(NATIVE_PLUGINS) FTE_CONFIG=$(GAME)
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.so" -exec mv '{}' ./ \;

fteqw-plugins-win32:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS=$(NATIVE_PLUGINS) FTE_CONFIG=$(GAME) FTE_TARGET=win32
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-win64:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS=$(NATIVE_PLUGINS) FTE_CONFIG=$(GAME) FTE_TARGET=win64
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-lin32:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS=$(NATIVE_PLUGINS) FTE_CONFIG=$(GAME) FTE_TARGET=linux32
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

fteqw-plugins-lin64:
	cd ThirdParty/fteqw/engine && $(MAKE) plugins-dbg NATIVE_PLUGINS=$(NATIVE_PLUGINS) FTE_CONFIG=$(GAME) FTE_TARGET=linux64
	find ThirdParty/fteqw/engine/debug/ -name "fteplug_*.dll" -exec mv '{}' ./ \;

$(ENGINE_BINARY):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) $(ENGINE_CLBUILD) FTE_CONFIG=$(GAME) ARCH=x86_64
	install -m 0777 $(ENGINE_BINARY) ./$(GAME_BINARY)

$(ENGINE_BINARY_WIN32): 
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	install -m 0777 $(ENGINE_BINARY_WIN32) $(BUILD_DIR)/$(NAME)-win/$(NAME)_x86.exe

$(ENGINE_BINARY_WIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	install -m 0777 $(ENGINE_BINARY_WIN64) $(BUILD_DIR)/$(NAME)-win/$(NAME)_x64.exe

$(ENGINE_BINARY_LIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=i686 FTE_TARGET=linux32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel ARCH=i686 FTE_TARGET=linux32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	install -m 0777 $(ENGINE_BINARY_LIN32) $(BUILD_DIR)/$(NAME)-linux/$(NAME)_x86

$(ENGINE_BINARY_LIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64 FTE_TARGET=linux64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel ARCH=x86_64 FTE_TARGET=linux64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	install -m 0777 $(ENGINE_BINARY_LIN64) $(BUILD_DIR)/$(NAME)-linux/$(NAME)_x64

$(ENGINE_DEDICATED):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-dbg FTE_CONFIG=$(GAME) ARCH=x86_64
	install -m 0777 $(ENGINE_DEDICATED) ./$(GAMEDS_BINARY)

$(ENGINE_DS_LIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel FTE_TARGET=win32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	install -m 0777 $(ENGINE_DS_WIN32) $(BUILD_DIR)/$(NAME)-win/$(NAME)DS_x86.exe

$(ENGINE_DS_LIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel FTE_TARGET=win64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	install -m 0777 $(ENGINE_DS_WIN64) $(BUILD_DIR)/$(NAME)-win/$(NAME)DS_x64.exe

$(ENGINE_DS_WIN32):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=i686 FTE_TARGET=linux32
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel ARCH=i686 FTE_TARGET=linux32 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	install -m 0777 $(ENGINE_DS_LIN32) $(BUILD_DIR)/$(NAME)-linux/$(NAME)DS_x86

$(ENGINE_DS_WIN64):
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64 FTE_TARGET=linux64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-rel ARCH=x86_64 FTE_TARGET=linux64 FTE_CONFIG=$(GAME)
	mkdir -p "$(BUILD_DIR)/$(NAME)-linux"
	install -m 0777 $(ENGINE_DS_LIN64) $(BUILD_DIR)/$(NAME)-linux/$(NAME)DS_x64

iqmtool:
	cd ThirdParty/fteqw/engine && $(MAKE) iqmtool
	install -m 0777 ./ThirdParty/fteqw/engine/release/iqmtool ./

imgtool:
	cd ThirdParty/fteqw/engine && $(MAKE) imgtool
	install -m 0777 ./ThirdParty/fteqw/engine/release/imgtool ./

fteqcc:
	cd ThirdParty/fteqw/engine && $(MAKE) qcc-rel
	install -m 0777 ./ThirdParty/fteqw/engine/release/fteqcc ./

# stock engine
fteqw:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=x86_64
	cd ThirdParty/fteqw/engine && $(MAKE) $(ENGINE_CLBUILD) ARCH=x86_64
	install -m 0777 ./ThirdParty/fteqw/engine/debug/fteqw ./

fteqwglqw64.exe:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs FTE_TARGET=win64
	cd ThirdParty/fteqw/engine && $(MAKE) m-rel FTE_TARGET=win64
	mkdir -p "$(BUILD_DIR)/$(NAME)-win"
	install -m 0777 $(ENGINE_BINARY_WIN64) $(BUILD_DIR)/fteqwglqw64.exe

fteqw-sv:
	cd ThirdParty/fteqw/engine && $(MAKE) makelibs ARCH=stock-x86_64
	cp $(GAME)/engine.h ./ThirdParty/fteqw/engine/common/config_$(GAME).h
	cd ThirdParty/fteqw/engine && $(MAKE) sv-dbg FTE_CONFIG=fteqw ARCH=stock-x86_64
	install -m 0777 ./ThirdParty/fteqw/engine/debug/fteqw ./fteqw

# third-party level editing software
radiant:
	if [ ! -d ThirdParty/gtkradiant ];then git clone https://github.com/TTimo/gtkradiant ThirdParty/gtkradiant;fi
	cd ThirdParty/gtkradiant && scons
	Tools/make_launcher.sh ./ThirdParty/gtkradiant/install/ ./radiant.bin radiant

netradiant-custom:
	if [ ! -d ThirdParty/netradiant-custom ];then git clone https://github.com/Garux/netradiant-custom ThirdParty/netradiant-custom;fi
	cd ThirdParty/netradiant-custom && $(MAKE)
	Tools/make_launcher.sh ./ThirdParty/netradiant-custom/install/ ./radiant.x86_64 netradiant-custom
