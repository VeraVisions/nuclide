/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
	decal.texture = sprintf("{scorch%d", floor(random(1,3)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}
