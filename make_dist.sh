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
cp ./valve.fmf ./_release/default.fmf
echo "version 2" > ./_release/installed.lst
echo "set updatemode \"1\"" >> ./_release/installed.lst
echo "set declined \"\"" >> ./_release/installed.lst
echo "sublist \"http://www.frag-net.com/dl/valve_packages\" \"\" \"enabled\"" >> ./_release/installed.lst

rm -rf ./_release/platform/test_maps.pk3dir

# build the tarball
export FILE_OUT=nuclide-$(date +%m-%d-%Y)
mv ./_release "./$FILE_OUT"
zip -9 -r "$FILE_OUT".zip "./$FILE_OUT"
gpg --output "./$FILE_OUT.sig" --detach-sig "./$FILE_OUT.zip"
