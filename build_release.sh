#!/bin/sh

copy_mod()
{
	mkdir ./_release/"$1"
	cp -R ./"$1"/data.pk3dir ./_release/"$1"/data.pk3dir
	cp ./"$1".fmf ./_release/"$1".fmf
	rm ./_release/"$1"/data.pk3dir/*.lno
}

copy_file()
{
	cp -R ./"$1" ./_release/"$1"
	
}

# clean up
mkdir ./_release

# build binaries
cd src
make
cd ..

# copy platform
cp -R ./platform ./_release/platform
cp -R ./doc ./_release/doc

# copy mods
copy_mod valve
copy_mod cstrike
copy_mod scihunt
copy_mod rewolf
copy_mod hunger

# spray logos
mkdir ./_release/logos
copy_file logos/README
copy_file logos/fte.png

# one last touch
touch ./_release/fteqw_goes_here
mv ./_release/doc/release-readme ./_release/README
mv ./_release/valve.fmf ./_release/default.fmf

# build the tarball
export FILE_OUT=nuclide-$(date +%m-%d-%Y)
mv ./_release "./$FILE_OUT"
tar zcvf "$FILE_OUT".tar.gz "./$FILE_OUT"
