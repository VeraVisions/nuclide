/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

typedef struct
{
	string name;
	vector color;
	int flags;
} decal_t;

enumflags
{
	DFLAG_ADDITIVE
};

#define COLOR_REDBLOOD [114,25,7]
#define COLOR_YELLOWBLOOD [248,224,122]

decal_t g_decalwad[] =
{
	{ "{bigblood1", COLOR_REDBLOOD, 0 },
	{ "{bigblood2", COLOR_REDBLOOD, 0 },
	{ "{bproof1", [255,255,255], DFLAG_ADDITIVE },
	{ "{break1", [255,255,255], DFLAG_ADDITIVE },
	{ "{break2", [255,255,255], DFLAG_ADDITIVE },
	{ "{break3", [255,255,255], DFLAG_ADDITIVE },
	{ "{blood1", COLOR_REDBLOOD, 0 },
	{ "{blood2", COLOR_REDBLOOD, 0 },
	{ "{blood3", COLOR_REDBLOOD, 0 },
	{ "{blood4", COLOR_REDBLOOD, 0 },
	{ "{blood5", COLOR_REDBLOOD, 0 },
	{ "{blood6", COLOR_REDBLOOD, 0 },
	{ "{blood7", COLOR_REDBLOOD, 0 },
	{ "{blood8", COLOR_REDBLOOD, 0 },
	{ "{bloodhand1", COLOR_REDBLOOD, 0 },
	{ "{bloodhand2", COLOR_REDBLOOD, 0 },
	{ "{bloodhand3", COLOR_REDBLOOD, 0 },
	{ "{bloodhand4", COLOR_REDBLOOD, 0 },
	{ "{bloodhand5", COLOR_REDBLOOD, 0 },
	{ "{bloodhand6", COLOR_REDBLOOD, 0 },
	{ "{hand1", COLOR_REDBLOOD, 0 },
	{ "{shot1", [255,255,255], 0 },
	{ "{shot2", [255,255,255], 0 },
	{ "{shot3", [255,255,255], 0 },
	{ "{shot4", [255,255,255], 0 },
	{ "{shot5", [255,255,255], 0 },
	{ "{bigshot1", [255,255,255], 0 },
	{ "{bigshot2", [255,255,255], 0 },
	{ "{bigshot3", [255,255,255], 0 },
	{ "{bigshot4", [255,255,255], 0 },
	{ "{bigshot5", [255,255,255], 0 },
	{ "{bigshot6", [255,255,255], 0 },
	{ "{scorch1", [255,255,255], 0 },
	{ "{scorch2", [255,255,255], 0 },
	{ "{scorch3", [255,255,255], 0 },
	{ "{yblood1", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood2", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood3", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood4", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood5", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood6", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood7", COLOR_YELLOWBLOOD, 0 },
	{ "{yblood8", COLOR_YELLOWBLOOD, 0 }
};
