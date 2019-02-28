

#define DECALS_MAX 16

#ifdef SSQC
entity g_decals;
void Decals_Init(void)
{
	entity nextdecal = spawn();
	g_decals = nextdecal;
	for ( int i = 0; i <= DECALS_MAX; i++ ) {
		nextdecal.classname = "decal";
		nextdecal.owner = spawn();
		
		if ( i == DECALS_MAX ) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = nextdecal.owner;
		}
	}
}

entity Decals_Next(void)
{
	entity ret = g_decals;
	g_decals = g_decals.owner;
	return ret;
}
#endif

void Decals_PlaceSmall(vector pos)
{
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next();
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
	entity decal = Decals_Next();
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
	entity decal = Decals_Next();
	setorigin(decal, pos);
	decal.texture = sprintf("{scorch%d", floor(random(1,3)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}
