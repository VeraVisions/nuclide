/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

typedef struct
{
	string name;
	vector color;
	int flags;
} decal_t;

enumflags
{
	DFLAG_ADDITIVE,
	DFLAG_INVERT
};

#define COLOR_REDBLOOD [114,25,7]
#define COLOR_YELLOWBLOOD [248,224,122]

decal_t g_decalwad[] =
{
	{ "{bigblood1", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bigblood2", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bproof1", [255,255,255], DFLAG_ADDITIVE },
	{ "{break1", [255,255,255], DFLAG_ADDITIVE },
	{ "{break2", [255,255,255], DFLAG_ADDITIVE },
	{ "{break3", [255,255,255], DFLAG_ADDITIVE },
	{ "{blood1", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood2", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood3", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood4", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood5", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood6", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood7", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{blood8", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand1", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand2", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand3", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand4", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand5", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{bloodhand6", COLOR_REDBLOOD, DFLAG_INVERT },
	{ "{hand1", COLOR_REDBLOOD, DFLAG_INVERT },
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
	{ "{yblood1", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood2", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood3", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood4", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood5", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood6", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood7", COLOR_YELLOWBLOOD, DFLAG_INVERT },
	{ "{yblood8", COLOR_YELLOWBLOOD, DFLAG_INVERT }
};
