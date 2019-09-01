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

var int autocvar_cl_decals = TRUE;

#include "decals.h"

#define DECALS_MAX 30

#ifdef SSQC
entity g_decals;
void Decals_Init(void)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
	entity nextdecal = spawn();
	g_decals = nextdecal;
	for (int i = 0; i <= DECALS_MAX; i++) {
		nextdecal.classname = "tempdecal";
		nextdecal.owner = spawn();
		
		if (i == DECALS_MAX) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = nextdecal.owner;
		}
	}
}

entity Decals_Next(vector pos)
{
	entity ret = g_decals;
	g_decals = g_decals.owner;

	/* Check for a tempdecal within a radius of 8 units and overwrite that one
	 * instead */
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		if (vlen(b.origin - pos) < 8) {
			return b;
		}
	}

	return ret;
}
#endif

void Decals_PlaceSmall(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{shot%d", floor(random(1,6)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceBig(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{bigshot%d", floor(random(1,6)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceGlass(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{break%d", floor(random(1,4)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceScorch(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{scorch%d", floor(random(1,4)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceDent(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{dent%d", floor(random(1,7)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceGauss(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = "{gaussshot1";
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

#ifdef CSQC

const string g_decalshader = \
	"{\n" \
		"polygonOffset\n" \
		"{\n" \
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc GL_ZERO GL_SRC_COLOR\n" \
		"}\n" \
	"}";

const string g_decalshader_add = \
	"{\n" \
		"polygonOffset\n" \
		"{\n" \
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc add\n" \
		"}\n" \
	"}";

float Decal_PreDraw(void)
{
	if (!autocvar_cl_decals) {
		return PREDRAW_NEXT;
	}

	adddecal(self.classname, self.origin, self.mins, self.maxs, self.color, 1.0f);
	addentity(self);
	return PREDRAW_NEXT;
}

void Decal_Parse(void)
{
	string decalname = "";
	string decalshader = "";

	self.origin[0] = readcoord();
	self.origin[1] = readcoord();
	self.origin[2] = readcoord();

	self.angles[0] = readcoord();
	self.angles[1] = readcoord();
	self.angles[2] = readcoord();
	self.classname = readstring();

	self.color = [1,1,1];

	for (int i = 0; i < g_decalwad.length; i++) {
		if (self.classname == g_decalwad[i].name) {
			self.color[0] = (g_decalwad[i].color[0] / 255);
			self.color[1] = (g_decalwad[i].color[1] / 255);
			self.color[2] = (g_decalwad[i].color[2] / 255);
			self.style = g_decalwad[i].flags;
			break;
		}
	}

	self.size = drawgetimagesize(self.classname);

	if (serverkeyfloat("*bspversion") == 30) {
		decalname = sprintf("decal_%s", self.classname);
		
		if (self.style & DFLAG_ADDITIVE) {
			decalshader = sprintf(g_decalshader_add, self.classname);
		} else {
			decalshader = sprintf(g_decalshader, self.classname);
		}
		shaderforname(decalname, decalshader);
		self.classname = decalname;
	}

	makevectors(self.angles);
	float surf = getsurfacenearpoint(world, self.origin);
	vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
	vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
	self.mins = v_up / self.size[0];
	self.maxs = t_dir / self.size[1];

	self.predraw = Decal_PreDraw;
	self.drawmask = MASK_ENGINE;
}
#endif
