CC=fteqcc

all:
	make menu
	make games
	make mods

menu:
	$(CC) menu-fn/progs.src

games:
	mkdir -p ../valve/data.pk3dir
	$(CC) client/valve/progs.src
	$(CC) server/valve/progs.src
	mkdir -p ../rewolf/data.pk3dir
	$(CC) client/rewolf/progs.src
	$(CC) server/rewolf/progs.src
	mkdir -p ../gearbox/data.pk3dir
	$(CC) client/gearbox/progs.src
	$(CC) server/gearbox/progs.src
	mkdir -p ../tfc/data.pk3dir
	$(CC) client/tfc/progs.src
	$(CC) server/tfc/progs.src
	
mods:
	#mkdir -p ../cstrike/data.pk3dir
	#$(CC) client/cstrike/progs.src
	#$(CC) server/cstrike/progs.src
	mkdir -p ../scihunt/data.pk3dir
	$(CC) client/scihunt/progs.src
	$(CC) server/scihunt/progs.src
	mkdir -p ../poke646/data.pk3dir
	$(CC) client/poke646/progs.src
	$(CC) server/poke646/progs.src
	mkdir -p ../hunger/data.pk3dir
	$(CC) client/hunger/progs.src
	$(CC) server/hunger/progs.src
