/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

static void
SurfData_ParseField(int i, int a)
{
	switch (argv(0)) {
	case "base":
		g_surfdata[i].m_strBase = argv(1);
		break;
	case "gamematerial":
		string mat = argv(1);
		g_surfdata[i].m_flMaterial = str2chr(mat, 0);
		break;
	case "thickness":
		g_surfdata[i].m_flThickness = stof(argv(1));
		break;
	case "density":
		g_surfdata[i].m_flDensity = stof(argv(1));
		break;
	case "elasticity":
		g_surfdata[i].m_flElasticity = stof(argv(1));
		break;
	case "friction":
		g_surfdata[i].m_flFriction = stof(argv(1));
		break;
	case "dampening":
		g_surfdata[i].m_flDampening = stof(argv(1));
		break;
	case "jumpfactor":
		g_surfdata[i].m_flJumpFactor = stof(argv(1));
		break;
	case "maxspeedfactor":
		g_surfdata[i].m_flMaxSpeedFactor = stof(argv(1));
		break;
	case "stepleft":
		g_surfdata[i].m_sndStepLeft = argv(1);
		break;
	case "stepright":
		g_surfdata[i].m_sndStepRight = argv(1);
		break;
	case "bulletimpact":
		g_surfdata[i].m_sndBulletImpact = argv(1);
		break;
	case "scraperough":
		g_surfdata[i].m_sndScrapeRough = argv(1);
		break;
	case "scrapesmooth":
		g_surfdata[i].m_sndScrapeSoft = argv(1);
		break;
	case "impacthard":
		g_surfdata[i].m_sndImpactHard = argv(1);
		break;
	case "impactsoft":
		g_surfdata[i].m_sndImpactSoft = argv(1);
		break;
	case "shake":
		g_surfdata[i].m_sndShake = argv(1);
		break;
	case "strain":
		g_surfdata[i].m_sndStrain = argv(1);
		break;
	case "break":
		g_surfdata[i].m_sndRoll = argv(1);
		break;
	case "roll":
	case "rolling":
		g_surfdata[i].m_sndBreak = argv(1);
		break;
	case "fx_bulletimpact":
	case "part_bulletimpact":
		g_surfdata[i].m_fxBulletImpact = argv(1);
#ifdef CLIENT
		g_surfdata[i].m_fxBulletImpactID = particleeffectnum(g_surfdata[i].m_fxBulletImpact);
#endif
		break;
	}
}

/* concerned with dealing with keeping track of braces and parsing lines */
static int
SurfData_Parse(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;
	static int i;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		/* increase counter when done */
		if (t_name)
			i++;

		braced--;
		t_name = "";
		break;
	default:
		if (braced == 1 && t_name != "") {
			SurfData_ParseField(i, c);
		} else if (braced == 0) {
			t_name = strtolower(line);
			hash_add(g_hashsurfdata, t_name, (int)i);
		}
	}
	return (0);
}

static int
SurfData_Load(string type)
{
	int index;

	if (!type)
		return -1;

	type = strtolower(type);

	index = (int)hash_get(g_hashsurfdata, type, -1);

	if (index < 0) {
		crossprint(sprintf("^1 SurfData_Load: type %s is not defined\n", type));
		return -1;
	} else {
		return index;
	}
}

/* stripped down ParseLine that just counts how many slots we have to allocate */
static void
SurfData_CountLine(string line)
{
	int c;
	string key;
	static string t_name;
	static int braced = 0;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		braced--;
		t_name = "";
		break;
	default:
		/* new definition starts */
		if (c == 1 && braced == 0) {
			t_name = strtolower(line);

			if (t_name)
				g_surfdata_count++;
		}
	}
	return;
}

int
SurfData_TexToSurfData(string tex_name)
{
	string mat = "";

	/* older map formats need their names 'fixed' */
	if (g_materialsAreLegacy == true)
		tex_name = Materials_FixName(tex_name);

	mat = (string)hash_get(g_hashMaterials, tex_name);

	if not (mat)
		return __NULL__;

	/* we got the surfdata string, return that */
	return SurfData_Load(mat);
}

/* Public API functions */
__variant
SurfData_GetInfo(int i, int type)
{
	if (i < 0)
		return __NULL__;

	switch (type)
	{
	case SURFDATA_MATERIAL:
		return __NULL__;
	case SURFDATA_THICKNESS:
		return (__variant)g_surfdata[i].m_flThickness;
	case SURFDATA_DENSITY:
		return (__variant)g_surfdata[i].m_flDensity;
	case SURFDATA_ELASTICITY:
		return (__variant)g_surfdata[i].m_flElasticity;
	case SURFDATA_FRICTION:
		return (__variant)g_surfdata[i].m_flFriction;
	case SURFDATA_DAMPENING:
		return (__variant)g_surfdata[i].m_flDampening;
	case SURFDATA_JUMPFACTOR:
		return (__variant)g_surfdata[i].m_flJumpFactor;
	case SURFDATA_MAXSPEEDFACTOR:
		return (__variant)g_surfdata[i].m_flMaxSpeedFactor;
	case SURFDATA_SND_STEPLEFT:
		return (__variant)g_surfdata[i].m_sndStepLeft;
	case SURFDATA_SND_STEPRIGHT:
		return (__variant)g_surfdata[i].m_sndStepRight;
	case SURFDATA_SND_BULLETIMPACT:
		return (__variant)g_surfdata[i].m_sndBulletImpact;
	case SURFDATA_SND_SCRAPEROUGH:
		return (__variant)g_surfdata[i].m_sndScrapeRough;
	case SURFDATA_SND_SCRAPESOFT:
		return (__variant)g_surfdata[i].m_sndScrapeSoft;
	case SURFDATA_SND_IMPACTHARD:
		return (__variant)g_surfdata[i].m_sndImpactHard;
	case SURFDATA_SND_IMPACTSOFT:
		return (__variant)g_surfdata[i].m_sndImpactSoft;
	case SURFDATA_SND_SHAKE:
		return (__variant)g_surfdata[i].m_sndShake;
	case SURFDATA_SND_STRAIN:
		return (__variant)g_surfdata[i].m_sndStrain;
	case SURFDATA_SND_ROLL:
		return (__variant)g_surfdata[i].m_sndRoll;
	case SURFDATA_SND_BREAK:
		return (__variant)g_surfdata[i].m_sndBreak;
	case SURFDATA_FX_BULLETIMPACT:
		return (__variant)g_surfdata[i].m_fxBulletImpact;
	case SURFDATA_FX_BULLETIMPACTID:
		return (__variant)g_surfdata[i].m_fxBulletImpactID;
	default:
		return __NULL__;
	}
}

void
SurfData_Shutdown(void)
{
	if (g_surfdata) {
		memfree(g_surfdata);
	}
	g_surfdata_count = 0;
	g_hashsurfdata = 0;
}

void
SurfData_Init(void)
{
	filestream fh;
	string line;
	int index;

	/* remove old data */
	SurfData_Shutdown();

	index = g_surfdata_count;

	/* create the hash-table if it doesn't exist */
	if (!g_hashsurfdata) {
		g_hashsurfdata = hash_createtab(2, HASH_ADD);
	}

	fh = fopen("scripts/surfaceproperties.txt", FILE_READ);
	if (fh < 0) {
		print("^1[SURFDATA] Can't find surfaceproperties.txt\n");
		return;
	}

	/* count content */
	while ((line = fgets(fh))) {
		SurfData_CountLine(line);
	}

	/* alocate our stuff */
	g_surfdata = (surfaceData_t *)memalloc(sizeof(surfaceData_t) * g_surfdata_count);

	/* Defaults */
	for (int i = 0; i < g_surfdata_count; i++) {
		g_surfdata[i].m_strBase = "";
		g_surfdata[i].m_flMaterial = -1;
		g_surfdata[i].m_flThickness = 1.0f;
		g_surfdata[i].m_flDensity = 1.0f;
		g_surfdata[i].m_flElasticity = 1.0f;
		g_surfdata[i].m_flFriction = 1.0f;
		g_surfdata[i].m_flDampening = 1.0f;
		g_surfdata[i].m_flJumpFactor = 1.0f;
		g_surfdata[i].m_flMaxSpeedFactor = 1.0f;

		g_surfdata[i].m_sndStepLeft = "";
		g_surfdata[i].m_sndStepRight = "";
		g_surfdata[i].m_sndBulletImpact = "";
		g_surfdata[i].m_sndScrapeRough = "";
		g_surfdata[i].m_sndScrapeSoft = "";
		g_surfdata[i].m_sndImpactHard = "";
		g_surfdata[i].m_sndImpactSoft = "";
		g_surfdata[i].m_sndShake = "";
		g_surfdata[i].m_sndStrain = "";
		g_surfdata[i].m_sndRoll = "";
		g_surfdata[i].m_sndBreak = "";
	}
	
	fseek(fh, 0);

	while ((line = fgets(fh))) {
		/* when we found it, quit */
		SurfData_Parse(line);
	}
	fclose(fh);

	for (int i = 0; i < g_surfdata_count; i++) {
		Sound_Precache(g_surfdata[i].m_sndStepLeft);
		Sound_Precache(g_surfdata[i].m_sndStepRight);
		Sound_Precache(g_surfdata[i].m_sndBulletImpact);
	}
}

static string g_curSurfData;
void
SurfData_SetStage(string type)
{
	if (!type)
		return;

	g_curSurfData = type;
}

int
SurfData_Finish(void)
{
	string toload = g_curSurfData;
	g_curSurfData = __NULL__;

	if (toload) {
		return SurfData_Load(toload);
	} else {
		return -1;
	}
}


#ifdef SERVER
void
SurfData_Impact_Net(entity e, vector org)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SURFIMPACT);
	WriteCoord(MSG_MULTICAST, org[0]);
	WriteCoord(MSG_MULTICAST, org[1]);
	WriteCoord(MSG_MULTICAST, org[2]);
	WriteEntity(MSG_MULTICAST, e);
	multicast(org, MULTICAST_PVS);
}

void
SurfData_ImpactID_Net(int id, vector org, vector ang)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SURFIMPACTID);
	WriteCoord(MSG_MULTICAST, org[0]);
	WriteCoord(MSG_MULTICAST, org[1]);
	WriteCoord(MSG_MULTICAST, org[2]);
	WriteCoord(MSG_MULTICAST, ang[0]);
	WriteCoord(MSG_MULTICAST, ang[1]);
	WriteCoord(MSG_MULTICAST, ang[2]);
	WriteInt(MSG_MULTICAST, id);
	multicast(org, MULTICAST_PVS);
}
#endif

#ifdef CLIENT
/** Called by EV_SURFIMPACT */
void
SurfData_Impact_Parse(void)
{
	entity surfnum = __NULL__;
	vector impactorg = [0.0f, 0.0f, 0.0f];

	impactorg[0] = readcoord();
	impactorg[1] = readcoord();
	impactorg[2] = readcoord();
	surfnum = findfloat(world, ::entnum, readentitynum()-1);

	string tex_name = getsurfacetexture(surfnum, getsurfacenearpoint(surfnum, impactorg));

	string impactsfx = SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_SND_BULLETIMPACT);

	string impactfx = SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_FX_BULLETIMPACT);
	float impactid = SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_FX_BULLETIMPACTID);

	NSLog("SurfData_Impact_Parse:");
	NSLog("\tent: %S texture: %S", surfnum.classname, tex_name);
	NSLog("\tplaying impact sfx %S at %v", impactsfx, impactorg);
	NSLog("\temitting impact fx %S at %v", impactfx, impactorg);

	Sound_PlayAt(impactorg, impactsfx);
	pointparticles( impactid, impactorg, [0,0,0], 1 );
}

/** Called by EV_SURFIMPACTID */
void
SurfData_ImpactID_Parse(void)
{
	int matid = __NULL__;
	vector impactorg = g_vec_null;
	vector impactang = g_vec_null;

	impactorg[0] = readcoord();
	impactorg[1] = readcoord();
	impactorg[2] = readcoord();

	impactang[0] = readcoord();
	impactang[1] = readcoord();
	impactang[2] = readcoord();
	matid = readint();

	string impactsfx = SurfData_GetInfo(matid, SURFDATA_SND_BULLETIMPACT);
	float impactid = SurfData_GetInfo(matid, SURFDATA_FX_BULLETIMPACTID);
	Sound_PlayAt(impactorg, impactsfx);
	pointparticles( impactid, impactorg, normalize(impactang), 1 );
}
#endif

void
SurfData_Impact(entity e, int fl, vector org, vector ang)
{
#ifdef SERVER
	static void SurfData_Impact_SurfaceParm(entity e, int fl, vector org, vector ang) {
		SurfData_Impact_Net(e, org);
	}

	/* the static world */
	if (e == world || e.takedamage == DAMAGE_NO) {
		if (trace_surfacename != "") {
			string n = strcat(dirname(e.model), "/", trace_surfacename);
			int texdata = SurfData_TexToSurfData(n);
			NSLog("SurfData_Impact: %S %i\n", n, texdata);
			SurfData_ImpactID_Net(texdata, org, ang);
		} else
			SurfData_Impact_SurfaceParm(e, fl, org, ang);
	} else { /* anything with takedamage = DAMAGE_YES is a NSurfacePropEntity. */
		NSSurfacePropEntity foo = (NSSurfacePropEntity)e;

		if (foo.HasSurfaceData() && foo.GetSurfaceData(SURFDATA_MATERIAL) != -1)
			FX_Impact(foo.GetSurfaceData(SURFDATA_FX_BULLETIMPACT), org, ang);
		else
			SurfData_Impact_SurfaceParm(e, fl, org, ang);
	}
#endif
}
