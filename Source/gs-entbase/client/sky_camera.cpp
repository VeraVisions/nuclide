/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var int autocvar_dev_skyscale = 0;

var vector g_skypos;
var int g_skyscale;

class sky_camera:CBaseEntity
{
	void() sky_camera;
	virtual void(string, string) SpawnKey;
};

void sky_camera::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "scale":
			g_skyscale = stoi(strKey);
			break;
		case "origin":
			origin = stov( strKey );
			setorigin( this, origin );
			g_skypos = origin;
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}

void sky_camera::sky_camera(void)
{
	g_skyscale = 16;
	Init();
}
