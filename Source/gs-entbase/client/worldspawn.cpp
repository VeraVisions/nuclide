/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* We only want to load this because we're in desperate need for the skyname
 * variable. Some maps like crossfire do not supply one because GS assumes
 * the default is 'desert'... so once this is done we'll kill it. */

class worldspawn:CBaseEntity
{
	virtual void(string, string) SpawnKey;
	virtual void() Initialized;
};

void worldspawn::Initialized(void)
{
	remove(this);
}

void worldspawn::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "skyname":
			Sky_Set(strKey);
			break;
		default:
			break;
	}
}
