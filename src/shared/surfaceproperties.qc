/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#warning SurfaceProperties should be stored in ncDict

static bool g_spDefaultSet;

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
		g_surfdata[i].m_sndBreak = argv(1);
		break;
	case "roll":
	case "rolling":
		g_surfdata[i].m_sndRoll = argv(1);
		break;
	case "fx_bulletimpact":
	case "part_bulletimpact":
		g_surfdata[i].m_fxBulletImpact = argv(1);
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
	static bool isDefault = false;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		/* increase counter when done */
		if (t_name) {
			/* we now apply our values to everything else. */
			if (isDefault) {
				for (int m = 1i; m < g_surfdata_count; m++) {
					g_surfdata[m].m_flMaterial = g_surfdata[0].m_flMaterial;
					g_surfdata[m].m_flThickness = g_surfdata[0].m_flThickness;
					g_surfdata[m].m_flDensity = g_surfdata[0].m_flDensity;
					g_surfdata[m].m_flElasticity = g_surfdata[0].m_flElasticity;
					g_surfdata[m].m_flFriction = g_surfdata[0].m_flFriction;
					g_surfdata[m].m_flDampening = g_surfdata[0].m_flDampening;
					g_surfdata[m].m_flJumpFactor = g_surfdata[0].m_flJumpFactor;
					g_surfdata[m].m_flMaxSpeedFactor = g_surfdata[0].m_flMaxSpeedFactor;
					g_surfdata[m].m_sndStepLeft = g_surfdata[0].m_sndStepLeft;
					g_surfdata[m].m_sndStepRight = g_surfdata[0].m_sndStepRight;
					g_surfdata[m].m_sndBulletImpact = g_surfdata[0].m_sndBulletImpact;
					g_surfdata[m].m_sndScrapeRough = g_surfdata[0].m_sndScrapeRough;
					g_surfdata[m].m_sndScrapeSoft = g_surfdata[0].m_sndScrapeSoft;
					g_surfdata[m].m_sndImpactHard = g_surfdata[0].m_sndImpactHard;
					g_surfdata[m].m_sndImpactSoft = g_surfdata[0].m_sndImpactSoft;
					g_surfdata[m].m_sndShake = g_surfdata[0].m_sndShake;
					g_surfdata[m].m_sndStrain = g_surfdata[0].m_sndStrain;
					g_surfdata[m].m_sndRoll = g_surfdata[0].m_sndRoll;
					g_surfdata[m].m_sndBreak = g_surfdata[0].m_sndBreak;
				}
			}

		}

		/* when we found it, quit */
		tokenize_console(t_name);
		hash_add(g_hashsurfdata, argv(0), (int)i);
		i++;

		braced--;
		t_name = "";
		break;
	default:
		if (braced == 1 && t_name != "") {
			SurfData_ParseField(i, c);
		} else if (braced == 0) {
			t_name = strtolower(line);

			if (t_name == "default") {
				isDefault = true;
			} else {
				isDefault = false;
			}
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
		ncError("SurfData %S is not defined.", type);
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
	static int braced = 0i;
	static int surfdataCount = 0i;

	c = tokenize_console(line);
	key = argv(0);

	switch(key) {
	case "{":
		braced++;
		break;
	case "}":
		braced--;
		surfdataCount++;
		t_name = "";
		break;
	default:
		/* new definition starts */
		if (c == 1 && braced == 0) {
			t_name = strtolower(argv(0));

			if (t_name) {
				g_surfdata_count++;
			}

			/* sanity test */
			if (t_name == "default" && surfdataCount == 0i) {
				g_spDefaultSet = true;
			}
		}
	}
	return;
}

int
SurfData_TexToSurfData(string tex_name)
{
	string mat = Materials_SurfDataForTexture(tex_name);

	/* we got the surfdata string, return that */
	return SurfData_Load(mat);
}

/* Public API functions */
__variant
SurfData_GetInfo(int i, int type)
{
	if (g_surfdata_count <= 0i) {
		return (__NULL__);
	}

	if (i < 0) {
		i = 0i;
	}

	switch (type) {
	case SURFDATA_MATERIAL:
		return (__variant)g_surfdata[i].m_flMaterial;
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
		return (__NULL__);
	}
}

static void
SurfData_CountEntries(string filePath)
{
	filestream fh;
	string line;

	fh = fopen(filePath, FILE_READ);

	if (fh < 0) {
		ncError("failed to parse %S!", filePath);
		return;
	}

	/* count surfaceproperty definitions */
	while ((line = fgets(fh))) {
		SurfData_CountLine(line);
	}

	fclose(fh);
}

static void
SurfData_LoadFile(string filePath)
{
	filestream fh;
	string line;

	fh = fopen(filePath, FILE_READ);

	if (fh < 0) {
		ncError("failed to parse %S!", filePath);
		return;
	}

	while ((line = fgets(fh))) {
		SurfData_Parse(line);
	}

	fclose(fh);
}

void
SurfData_Shutdown(void)
{
	if (g_surfdata) {
		memfree(g_surfdata);
	}

	g_surfdata_count = 0i;
	g_hashsurfdata = 0;
	g_spDefaultSet = false;
}

void
SurfData_Init(void)
{
	filestream fh;
	string line;
	int index;
	int args;
	bool fromManifest = true;
	int spMemSize;
	searchhandle sh;

	InitStart();

	/* remove old data */
	SurfData_Shutdown();

	index = g_surfdata_count;

	/* if it already exists, detroy it first */
	if (g_hashsurfdata) {
		hash_destroytab(g_hashsurfdata);
	}

	fh = fopen("scripts/surfaceproperties_manifest.txt", FILE_READ);

	/* it's OK for one to not exist... */
	if (fh < 0) {
		ncWarning("missing scripts/surfaceproperties_manifest.txt!");
		fromManifest = false;

		/* older games may only have one file */
		fh = fopen("scripts/surfaceproperties.txt", FILE_READ);

		/* now we're out of options. sorry */
		if (fh < 0) {
			ncError("missing scripts/surfaceproperties.txt");
			InitEnd();
			return;
		}

		SurfData_CountEntries("scripts/surfaceproperties.txt");
	} else {

		/* first we count all valid entries. yes, this is not how you're meant to parse it, but w/e */
		while ((line = fgets(fh))) {
			args = tokenize_console(line);

			if (args == 2) {
				if (argv(0) == "file") {
					SurfData_CountEntries(argv(1));
				}
			}
		}
	}

	/* TODO: ensure that the above paths aren't necessary? */
	sh = search_begin("scripts/surfaceproperties/*.txt", TRUE, TRUE);
	for (int i = 0; i < search_getsize(sh); i++) {
		SurfData_CountEntries(search_getfilename(sh, i));
	}

	/* now that we've counted the valid entries, alocate our stuff */
	spMemSize = sizeof(surfaceData_t) * g_surfdata_count;
	g_surfdata = (surfaceData_t *)memalloc(spMemSize);

	if (!g_surfdata) {
		ncError("Memory allocation failed for %i bytes.", spMemSize);
		g_surfdata_count = 0;
		InitEnd();
		return;
	}

	g_hashsurfdata = hash_createtab(2, HASH_ADD);

	/* Internal, defaults. Most of them get overriden by the first entry ('default') */
	for (int i = 0i; i < g_surfdata_count; i++) {
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
		g_surfdata[i].m_fxBulletImpact = "";
		g_surfdata[i].m_fxBulletImpactID = -1;
	}

	fseek(fh, 0);

	if (fromManifest == false) {
		SurfData_LoadFile("scripts/surfaceproperties.txt");
	} else {
		while ((line = fgets(fh))) {
			args = tokenize_console(line);

			if (args == 2) {
				if (argv(0) == "file") {
					SurfData_LoadFile(argv(1));
				}
			}
		}
	}

	fclose(fh);

	/* GMod search paths */
	for (int i = 0; i < search_getsize(sh); i++) {
		SurfData_LoadFile(search_getfilename(sh, i));
	}

#if 1
	for (int i = 1i; i < g_surfdata_count; i++) {
		int matID = -1;

		if (!STRING_SET(g_surfdata[i].m_strBase)) {
			continue;
		}

		matID = SurfData_Load(g_surfdata[i].m_strBase);

		/* ugly inheriting */
		if (matID == -1) {
			continue;
		}

		//printf("%i inheriting %S from %i\n", i, g_surfdata[i].m_strBase, matID);

		if (g_surfdata[i].m_flMaterial == -1) {
			g_surfdata[i].m_flMaterial = g_surfdata[matID].m_flMaterial;
			//printf("%i inheriting material %d %d from %i\n", i, g_surfdata[i].m_flMaterial, g_surfdata[matID].m_flMaterial, matID);
		}

		if (!STRING_SET(g_surfdata[i].m_sndStepLeft))
			g_surfdata[i].m_sndStepLeft = g_surfdata[matID].m_sndStepLeft;
		if (!STRING_SET(g_surfdata[i].m_sndStepRight))
			g_surfdata[i].m_sndStepRight = g_surfdata[matID].m_sndStepRight;
		if (!STRING_SET(g_surfdata[i].m_sndBulletImpact))
			g_surfdata[i].m_sndBulletImpact = g_surfdata[matID].m_sndBulletImpact;
		if (!STRING_SET(g_surfdata[i].m_sndScrapeRough))
			g_surfdata[i].m_sndScrapeRough = g_surfdata[matID].m_sndScrapeRough;
		if (!STRING_SET(g_surfdata[i].m_sndScrapeSoft))
			g_surfdata[i].m_sndScrapeSoft = g_surfdata[matID].m_sndScrapeSoft;
		if (!STRING_SET(g_surfdata[i].m_sndImpactHard))
			g_surfdata[i].m_sndImpactHard = g_surfdata[matID].m_sndImpactHard;
		if (!STRING_SET(g_surfdata[i].m_sndImpactSoft))
			g_surfdata[i].m_sndImpactSoft = g_surfdata[matID].m_sndImpactSoft;
		if (!STRING_SET(g_surfdata[i].m_sndShake))
			g_surfdata[i].m_sndShake = g_surfdata[matID].m_sndShake;
		if (!STRING_SET(g_surfdata[i].m_sndStrain))
			g_surfdata[i].m_sndStrain = g_surfdata[matID].m_sndStrain;
		if (!STRING_SET(g_surfdata[i].m_sndRoll))
			g_surfdata[i].m_sndRoll = g_surfdata[matID].m_sndRoll;
		if (!STRING_SET(g_surfdata[i].m_sndBreak))
			g_surfdata[i].m_sndBreak = g_surfdata[matID].m_sndBreak;
		if (!STRING_SET(g_surfdata[i].m_fxBulletImpact))
			g_surfdata[i].m_fxBulletImpact = g_surfdata[matID].m_fxBulletImpact;

	}
#endif

	for (int i = 0i; i < g_surfdata_count; i++) {
		precache.Sound(g_surfdata[i].m_sndStepLeft);
		precache.Sound(g_surfdata[i].m_sndStepRight);
		precache.Sound(g_surfdata[i].m_sndBulletImpact);
		precache.Sound(g_surfdata[i].m_sndScrapeRough);
		precache.Sound(g_surfdata[i].m_sndScrapeSoft);
		precache.Sound(g_surfdata[i].m_sndImpactHard);
		precache.Sound(g_surfdata[i].m_sndImpactSoft);
		precache.Sound(g_surfdata[i].m_sndShake);
		precache.Sound(g_surfdata[i].m_sndStrain);
		precache.Sound(g_surfdata[i].m_sndRoll);
		precache.Sound(g_surfdata[i].m_sndBreak);
#if 1
		/* HACK: HL2 hard-codes these! */
		if (!STRING_SET(g_surfdata[i].m_fxBulletImpact) && g_surfdata[i].m_flMaterial != -1) {
			string newFXImpact = "";

			switch (g_surfdata[i].m_flMaterial) {
			case 'Y':
				newFXImpact = "impact.glass";
				break;
			case 'S':
				newFXImpact = "impact.water";
				break;
			case 'C':
			case 'T':
				newFXImpact = "impact.concrete";
				break;
			case 'W':
				newFXImpact = "impact.wood";
				break;
			case 'D':
				newFXImpact = "impact.dirt";
				break;
			case 'N':
				newFXImpact = "impact.sand";
				break;
			case 'A':
				newFXImpact = "impact.alien";
				break;
			case 'M':
			case 'G':
			case 'V':
				newFXImpact = "impact.metal";
				break;
			case 'C':
				newFXImpact = "impact.computer";
				break;
			case 'F':
				newFXImpact = "impact.flesh";
				break;
			}

			g_surfdata[i].m_fxBulletImpact = newFXImpact;
		}
#endif

		if (STRING_SET(g_surfdata[i].m_fxBulletImpact)) {
			g_surfdata[i].m_fxBulletImpactID = particleeffectnum(g_surfdata[i].m_fxBulletImpact);
		}
	}

	search_end(sh);
	ncLog("...SurfData initialized with %i entries.", g_surfdata_count);
	InitEnd();
}

static string g_curSurfData;
void
SurfData_SetStage(string type)
{
	if (!type) {
		return;
	}

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
	vector impactorg = g_vec_null;
	vector impactang = g_vec_null;
	float impactSurface;
	int matid;

	impactorg[0] = readcoord();
	impactorg[1] = readcoord();
	impactorg[2] = readcoord();
	surfnum = findfloat(world, ::entnum, readentitynum()-1);

	impactSurface = getsurfacenearpoint(surfnum, impactorg);
	impactang = getsurfacenormal(surfnum, impactSurface);

	string tex_name = getsurfacetexture(surfnum, impactSurface);
	matid = SurfData_TexToSurfData(tex_name);
	string impactsfx = SurfData_GetInfo(matid, SURFDATA_SND_BULLETIMPACT);
	string impactfx = SurfData_GetInfo(matid, SURFDATA_FX_BULLETIMPACT);
	float impactid = SurfData_GetInfo(matid, SURFDATA_FX_BULLETIMPACTID);

	SoundDef_PlayAt(impactorg, impactsfx);

#if 0
	impactid = particleeffectnum("impact.concrete");
#endif

	pointparticles( impactid, impactorg, normalize(impactang), 1 );
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
	SoundDef_PlayAt(impactorg, impactsfx);

	pointparticles( impactid, impactorg, normalize(impactang), 1 );
}
#endif

void
SurfData_Impact(entity e, vector org, vector ang)
{
#ifdef SERVER
	static void SurfData_Impact_SurfaceParm(entity e, vector org, vector ang) {
		SurfData_Impact_Net(e, org);
	}

	/* the static world */
	if (e == world || e.takedamage == DAMAGE_NO) {
		if (trace_surfacename != "") {
			string n = strcat(dirname(e.model), "/", trace_surfacename);
			int texdata = SurfData_TexToSurfData(n);
			SurfData_ImpactID_Net(texdata, org, ang);
		} else {
			SurfData_Impact_SurfaceParm(e, org, ang);
		}
	} else { /* anything with else is a NSurfacePropEntity. */
		ncSurfacePropEntity foo = (ncSurfacePropEntity)e;

		if (foo.HasSurfaceData()) {
			SurfData_ImpactOfType(foo.m_surfdataID, org, ang);
			//printf("Prop Impact Send %i\n", foo.m_surfdataID);
		} else {
			SurfData_Impact_SurfaceParm(e, org, ang);
		}
	}
#endif
}

void
SurfData_ImpactOfType(int materialID, vector worldPosition, vector impactNormal)
{
#ifdef SERVER
// 	printf("Impact: %i %s\n", materialID, SurfData_GetInfo(materialID, SURFDATA_FX_BULLETIMPACT));
	SurfData_ImpactID_Net(materialID, worldPosition, impactNormal);
#endif
	/* TODO: client side only version */
}

void
SurfData_ImpactOfNamedType(string materialName, vector worldPosition, vector impactNormal)
{
	int index = (int)hash_get(g_hashsurfdata, materialName, -1);
	SurfData_ImpactOfType(index, worldPosition, impactNormal);
}
