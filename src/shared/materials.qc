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

static int g_mat_total;
/* legacy material compatibility */

/** hlmaterial to classname mapper table */
typedef struct
{
	string idx;
	string matclass;
} hlmaterials_lut;

hashtable g_hashMaterials;

hlmaterials_lut *g_hlmlut;
var int g_hlmlut_count;
var int g_hlmaterial_entries;

var bool g_materialsAreLegacy;

/* FIXME: world.... sigh, we should box this into a worldspawn class */
.string materials_file;

// Impact types
typedef enum
{
	IMPACT_MELEE,
	IMPACT_EXPLOSION,
	IMPACT_DEFAULT,
	IMPACT_ALIEN,
	IMPACT_COMPUTER,
	IMPACT_CONCRETE,
	IMPACT_DIRT,
	IMPACT_FLESH,
	IMPACT_FOLIAGE,
	IMPACT_GLASS,
	IMPACT_GRATE,
	IMPACT_METAL,
	IMPACT_SAND,
	IMPACT_SLOSH,
	IMPACT_SNOW,
	IMPACT_TILE,
	IMPACT_VENT,
	IMPACT_WOOD
} impactType_t;

typedef enum
{
	GSMATERIAL_GLASS,
	GSMATERIAL_WOOD,
	GSMATERIAL_METAL,
	GSMATERIAL_FLESH,
	GSMATERIAL_CINDER,
	GSMATERIAL_TILE,
	GSMATERIAL_COMPUTER,
	GSMATERIAL_GLASS_UNBREAKABLE,
	GSMATERIAL_ROCK,
	GSMATERIAL_NONE
} materialType_t;


/* q3 bsp base flags */
#define SURF_NODAMAGE		0x1i		// never give falling damage
#define SURF_SLICK		0x2i		// effects game physics
#define SURF_SKY		0x4i		// lighting from environment map
#define SURF_LADDER		0x8i		// climb this surface
#define SURF_NOIMPACT		0x10i		// don't make missile explosions
#define SURF_NOMARKS		0x20i		// don't leave missile marks
#define SURF_Q3FLESH		0x40i		// make flesh sounds and effects
#define SURF_NODRAW		0x80i		// don't generate a drawsurface at all
#define SURF_HINT		0x100i		// make a primary bsp splitter
#define SURF_SKIP		0x200i		// completely ignore, allowing non-closed brushes
#define SURF_NOLIGHTMAP		0x400i		// surface doesn't need a lightmap
#define SURF_POINTLIGHT		0x800i		// generate lighting info at vertexes
#define SURF_METALSTEPS		0x1000i		// clanking footsteps
#define SURF_NOSTEPS		0x2000i		// no footstep sounds
#define SURF_NONSOLID		0x4000i		// don't collide against curves with this set
#define SURF_LIGHTFILTER	0x8000i		// act as a light filter during q3map -light
#define SURF_ALPHASHADOW	0x10000i	// do per-pixel light shadow casting in q3map
#define SURF_NODLIGHT		0x20000i	// don't dlight even if solid (solid lava, skies)
#define SURF_DUST		0x40000i	// leave a dust trail when walking on this surface

/* behaviour surfaceflags */
#define SURF_LEAKSTEAM		0x00080000i /* when shot, the material emits steam */
#define SURF_LEAKWATER		0x00100000i /* when shot, the material emits water */
#define SURF_RESERVED1		0x00200000i
#define SURF_RESERVED2		0x00400000i
#define SURF_RESERVED3		0x00800000i
#define SURF_RESERVED4		0x01000000i
#define SURF_RESERVED5		0x02000000i
#define SURF_RESERVED6		0x04000000i
#define SURF_PENETRATE		0x08000000i

/* old TW material surfaceflags (need to be masked) */
#define SURF_MASK		0x0FFFFFFFi
#define SURF_ALIEN		0x10000000i
#define SURF_BLOODYFLESH	0x20000000i
#define SURF_FOLIAGE		0x30000000i
#define SURF_COMPUTER		0x40000000i
#define SURF_DIRT		0x50000000i
#define SURF_VENT		0x60000000i
#define SURF_GRATE		0x70000000i
#define SURF_METAL		0x80000000i
#define SURF_GLASS		0x90000000i
#define SURF_SAND		0xA0000000i
#define SURF_SLOSH		0xB0000000i
#define SURF_SNOW		0xC0000000i
#define SURF_TILE		0xD0000000i
#define SURF_WOOD		0xE0000000i
#define SURF_CONCRETE		0xF0000000i

const int CONTENTBIT_NONE		= 0x00000000i;

const int CONTENTBIT_SOLID		= 0x00000001i
;	/* SOLID_BSP */
const int CONTENTBIT_UNUSED1		= 0x00000002i
;
const int CONTENTBIT_UNUSED2		= 0x00000004i
;
const int CONTENTBIT_LAVA		= 0x00000008i;
	/* surfaceParm lava */

const int CONTENTBIT_SLIME		= 0x00000010i;
	/* surfaceParm slime */
const int CONTENTBIT_WATER		= 0x00000020i;
	/* surfaceParm water */
const int CONTENTBIT_UNUSED3		= 0x00000040i
;
const int CONTENTBIT_GRENADECLIP	= 0x00000080i
;	/* surfaceParm grenadeclip */

const int CONTENTBIT_UNUSED4		= 0x00000100i;
const int CONTENTBIT_UNUSED5		= 0x00000200i;
const int CONTENTBIT_UNUSED6		= 0x00000400i
;
const int CONTENTBIT_UNUSED7		= 0x00000800i
;

const int CONTENTBIT_UNUSED8		= 0x00001000i;
const int CONTENTBIT_UNUSED9		= 0x00002000i;
const int CONTENTBIT_FTELADDER		= 0x00004000i;	/* surfaceparm climb */
const int CONTENTBIT_VEHICLECLIP		= 0x00008000i;

const int CONTENTBIT_PLAYERCLIP		= 0x00010000i;
	/* surfaceParm playerclip */
const int CONTENTBIT_MONSTERCLIP	= 0x00020000i;
	/* surfaceParm monsterclip */
const int CONTENTBIT_PROJECTILE		= 0x00040000i;
const int CONTENTBIT_UNUSED12		= 0x00080000i;

const int CONTENTBIT_CLUSTERPORTAL	= 0x00100000i;
const int CONTENTBIT_DONOTENTER		= 0x00200000i;
const int CONTENTBIT_BOTCLIP		= 0x00400000i
;	/* surfaceParm botclip */
const int CONTENTBIT_MOVER		= 0x00800000i
;

const int CONTENTBIT_UNUSED13		= 0x01000000i
;
const int CONTENTBIT_BODY		= 0x02000000i;	/* SOLID_BBOX/SLIDEBOX */
const int CONTENTBIT_CORPSE		= 0x04000000i;	/* SOLID_CORPSE */
const int CONTENTBIT_UNUSED14		= 0x08000000i;

const int CONTENTBIT_UNUSED15		= 0x10000000i;
const int CONTENTBIT_Q2LADDER		= 0x20000000i;	/* Q2BSP climbables */
const int CONTENTBIT_UNUSED16		= 0x40000000i;
const int CONTENTBIT_SKY		= 0x80000000i;	/* Q1BSP only! */

/* a bit content group */
const int CONTENTBITS_MONSTER = CONTENTBIT_SOLID|CONTENTBIT_BODY|CONTENTBIT_MONSTERCLIP|CONTENTBIT_BOTCLIP;


/* this is used for material-lookups using the external materials.txt file
 * method used in Half-Life. In that environment we have to strip any
 * prefixes and limit our material-name to 12 chars for everything to be
 * identified correctly */
static string
Materials_FixName(string old_name)
{
	string tex_name = old_name;

	/* strip the first 2 chars when they're frame/random indicators */
	if (str2chr(tex_name, 0) == '-')
		tex_name = substring(tex_name, 2, -1);
	else if (str2chr(tex_name, 0) == '+')
		tex_name = substring(tex_name, 2, -1);

	/* also not allowed */
	if (str2chr(tex_name, 0) == '~')
		tex_name = substring(tex_name, 1, -1);
	else if (str2chr(tex_name, 0) == '{')
		tex_name = substring(tex_name, 1, -1);

	/* limit to 12 chars! */
	tex_name = substring(tex_name, 0, 12);

	//NSLog("%s > %s", old_name, tex_name);

	return tex_name;
}

string
Materials_SurfDataForTexture(string textureName)
{
	string mat = "";

	/* older map formats need their names 'fixed' */
	if (g_materialsAreLegacy == true) {
		textureName = Materials_FixName(textureName);
	}

	mat = (string)hash_get(g_hashMaterials, textureName);

	if not (mat)
		return __NULL__;

	return (mat);
}


/* general purpose functions to interact with the material system */
static void
Materials_LoadFromText(string filename)
{
#if 0
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);

	if (fileMaterial >= 0) {
		//print(strcat("parsing material assignments from ", filename,"\n"));

		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = strtoupper(argv(0));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(g_hashMaterials, tex_name, str2chr(mat_type, 0), EV_STRING);
			}
		}

		fclose(fileMaterial);
	} else {
		NSError("Missing file %s", filename);
	}
#endif
}

static void
Materials_LoadFromMat(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string materialname = substring(filename, 0, -5);
	string extension = substring(filename, strlen(filename) - 3, 3);
	string command, parameters;

	fileMaterial = fopen(filename, FILE_READ);

	/* load the .mat and find which material we're supposed to be using */
	if (fileMaterial >= 0) {
		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				command = strtolower(argv(0));
				parameters = argv(1);

				if (command == "surfaceprop") {
					hash_add(g_hashMaterials, materialname, parameters, EV_STRING);
					g_mat_total++;
					//print(sprintf("added Material %S type %S\n", materialname, parameters));
					break;
				}
			}
		}

		fclose(fileMaterial);
	}
}

/** FIXME: all this should be done exclusively in surfaceproperties.qc, however that
is currently server-side only. Make it shared and then we can get rid of this
whole file! */

/** loads a temporary mapper so we can map letters to class names. */
static void
Materials_Mapper_Init(void)
{
	string sTemp;
	int c = 0;
	filestream fileLUT;
	string spname = "";
	bool inbrace = false;

	fileLUT = fopen("scripts/surfaceproperties.txt", FILE_READ);
	g_hlmlut_count = 0;

	/* count valid entries. */
	if (fileLUT >= 0) {
		while ((sTemp = fgets(fileLUT))) {
			if (tokenize_console(sTemp) == 2) {
				if (argv(0) == "gamematerial")
					g_hlmlut_count++;
			}
		}
	}

	/* back to the beginning... */
	fseek(fileLUT, 0);
	g_hlmlut = memalloc(sizeof(hlmaterials_lut) * g_hlmlut_count);

	/* read in the elements */
	if (fileLUT >= 0) {
		while ((sTemp = fgets(fileLUT))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				if (argv(0) == "gamematerial") {
					g_hlmlut[c].idx = argv(1);
					g_hlmlut[c].matclass = spname;
					c++;
				}
			}
			
			if (argv(0) == "{")
				inbrace = true;
			else if (argv(0) == "}")
				inbrace = false;
			else if (inbrace == false)
				spname = argv(0);
		}
	}
}

/** takes a mat id and returns a classname */
static string
Materials_Mapper_Lookup(string character)
{
	int i;

	for (i = 0; i < g_hlmlut_count; i++)
		if (g_hlmlut[i].idx == character)
			return g_hlmlut[i].matclass;

	return __NULL__;
}

/** unallocates the mapper */
static void
Materials_Mapper_Shutdown(void)
{
	g_hlmlut_count = 0;
	memfree(g_hlmlut);
}

/** loads a materials.txt type file into our hashtable. */
static void
Materials_LoadFromLegacyText(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);
	if (fileMaterial >= 0) {
		//print(strcat("parsing material definitions from ", filename,"\n"));
		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = Materials_Mapper_Lookup(strtoupper(argv(0)));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(g_hashMaterials, tex_name, mat_type, EV_STRING);
				///print(sprintf("hlmaterial: %S %S\n", tex_name, mat_type));
				g_hlmaterial_entries++;
				g_mat_total++;
			}
		}
		fclose(fileMaterial);
	} else {
		NSError("Missing file %s", filename);
	}
}

void
Materials_Init(void)
{
	InitStart();
	g_mat_total = 0i;

	g_hashMaterials = __NULL__;
	g_hashMaterials = hash_createtab(2, EV_STRING | HASH_REPLACE);

	/* save away the type of material formats we're dealing with */
	switch (serverkeyfloat("*bspversion")) {
	case BSPVER_Q3: /* Q3 */
	case BSPVER_RTCW: /* RtCW */
	case BSPVER_RBSP: /* RFVBSP */
		g_materialsAreLegacy = false;
		break;
	case BSPVER_HL:
	default:
		g_materialsAreLegacy = true;
	}

	/* we're dealing with legacy materials */
	if (g_materialsAreLegacy) {
		string wastesName = sprintf("maps/%s.mat", mapname);
		string svenName = sprintf("maps/%s_materials.txt", mapname);

		/* prepare the mapper */
		Materials_Mapper_Init();

		/* the base definition, every GoldSrc game has this */
		Materials_LoadFromLegacyText("sound/materials.txt");

		/* Sven Coop 5.0 loads it from a worldspawn key */
		if (world.materials_file)
			Materials_LoadFromLegacyText(world.materials_file);

		/* search through our sound dir for material definitions */
		searchhandle pm;
		pm = search_begin("sound/materials_*.txt", TRUE, TRUE);
		for (int i = 0; i < search_getsize(pm); i++) {
			Materials_LoadFromLegacyText(search_getfilename(pm, i));
		}
		search_end(pm);

		/* the way TW did it back in '03 */
		if (fileExists(wastesName))
			Materials_LoadFromLegacyText(wastesName);

		/* Trinity-Renderer does it this way */
		if (fileExists(svenName))
			Materials_LoadFromLegacyText(svenName);

		/* no longer needed! */
		Materials_Mapper_Shutdown();
	} else {
		/* iterate through our mat files */
		searchhandle searchy = search_begin("textures/*/*.mat", SEARCH_NAMESORT, TRUE);
		for (int i = 0; i < search_getsize(searchy); i++) {
			Materials_LoadFromMat(search_getfilename(searchy, i));
		}
		search_end(searchy);

		/* don't judge me for this abhorrent path, father */
		searchhandle mdlsearch = search_begin("models/*/*/*/*.mat:models/*/*/*.mat:models/*/*.mat:models/*.mat", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);
		for (int i = 0; i < search_getsize(mdlsearch); i++) {
			string mdlmat = search_getfilename(mdlsearch, i);
			//printf("model: %S\n", mdlmat);
			Materials_LoadFromMat(mdlmat);
		}
		search_end(mdlsearch);
	}

	NSLog("material data initialized with %i entries.", g_mat_total);
	InitEnd();
}
