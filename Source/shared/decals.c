/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#include "decals.h"

#define DECALS_MAX 30

#ifdef SSQC
entity g_decals;
void Decals_Init(void)
{
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

void Decals_PlaceScorch(vector pos)
{
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

#ifdef CSQC

const string g_decalshader = \
	"{\n" \
		"polygonOffset\n" \
		"{\n"\
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc GL_ZERO GL_SRC_COLOR\n" \
		"}\n" \
	"}";

float Decal_PreDraw(void)
{
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

	for (int i = 0; i < g_decalwad.length; i++) {
		if (self.classname == g_decalwad[i].name) {
			self.color[0] = (g_decalwad[i].color[0] / 255);
			self.color[1] = (g_decalwad[i].color[1] / 255);
			self.color[2] = (g_decalwad[i].color[2] / 255);
			break;
		}
	}

	self.size = drawgetimagesize(self.classname);

	if (serverkeyfloat("*bspversion") == 30) {
		decalname = sprintf("decal_%s", self.classname);
		decalshader = sprintf(g_decalshader, self.classname);
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
