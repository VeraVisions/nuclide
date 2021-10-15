/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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


/* HLBSP materials.txt character id's */
//#define MATID_UNUSED1			'A'
#define MATID_BLOODYFLESH		'B'
#define MATID_CONCRETE			'C'
#define MATID_DIRT			'D'
//#define MATID_UNUSED2			'E'
#define MATID_FLESH			'F'
#define MATID_GRATE			'G'
#define MATID_ALIEN			'H'
//#define MATID_UNUSED3			'I'
//#define MATID_GRASS			'J'
//#define MATID_PLASTIC			'L'
#define MATID_METAL			'M'
#define MATID_FOLIAGE			'O'
#define MATID_COMPUTER			'P'
//#define MATID_ASPHALT			'Q'
//#define MATID_BRICK			'R'
#define MATID_SLOSH			'S'
#define MATID_TILE			'T'
#define MATID_CARDBOARD			'U'
#define MATID_VENT			'V'
#define MATID_WOOD			'W'
//#define MATID_UNUSED4			'X'
#define MATID_GLASS			'Y'
//#define MATID_UNUSED5			'Z'

/* CS defines snow as 'N' on GoldSrc, whereas in Source it's reserved for sand */
#ifdef CSTRIKE
#define MATID_SNOW			'N'
#define MATID_SAND			'K'
#else
#define MATID_SNOW			'K'
#define MATID_SAND			'N'
#endif

/* modern additions, not implemented yet */
#define MATID_CLAY			1
#define MATID_PLASTER			2
#define MATID_ROCK			3
#define MATID_RUBBER			4
#define MATID_SHEETROCK			5
#define MATID_CLOTH			6
#define MATID_CARPET			7
#define MATID_PAPER			8
#define MATID_UPHOLSTERY		9
#define MATID_PUDDLE			10
#define MATID_MUD			11
#define MATID_SANDBARREL		12


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
#define SURF_RESERVED7		0x08000000i

/* material surfaceflags (need to be masked) */
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

const int CONTENTBIT_SOLID		= 0x00000001i;	/* SOLID_BSP */
const int CONTENTBIT_UNUSED1		= 0x00000002i;
const int CONTENTBIT_UNUSED2		= 0x00000004i;
const int CONTENTBIT_LAVA		= 0x00000008i;	/* surfaceParm lava */

const int CONTENTBIT_SLIME		= 0x00000010i;	/* surfaceParm slime */
const int CONTENTBIT_WATER		= 0x00000020i;	/* surfaceParm water */
const int CONTENTBIT_UNUSED3		= 0x00000040i;
const int CONTENTBIT_GRENADECLIP	= 0x00000080i;	/* surfaceParm grenadeclip */

const int CONTENTBIT_UNUSED4		= 0x00000100i;
const int CONTENTBIT_UNUSED5		= 0x00000200i;
const int CONTENTBIT_UNUSED6		= 0x00000400i;
const int CONTENTBIT_UNUSED7		= 0x00000800i;

const int CONTENTBIT_UNUSED8		= 0x00001000i;
const int CONTENTBIT_UNUSED9		= 0x00002000i;
const int CONTENTBIT_FTELADDER		= 0x00004000i;	/* surfaceparm climb */
const int CONTENTBIT_UNUSED10		= 0x00008000i;

const int CONTENTBIT_PLAYERCLIP		= 0x00010000i;	/* surfaceParm playerclip */
const int CONTENTBIT_MONSTERCLIP	= 0x00020000i;	/* surfaceParm monsterclip */
const int CONTENTBIT_UNUSED11		= 0x00040000i;
const int CONTENTBIT_UNUSED12		= 0x00080000i;

const int CONTENTBIT_CLUSTERPORTAL	= 0x00100000i;
const int CONTENTBIT_DONOTENTER		= 0x00200000i;
const int CONTENTBIT_BOTCLIP		= 0x00400000i;	/* surfaceParm botclip */
const int CONTENTBIT_MOVER		= 0x00800000i;

const int CONTENTBIT_UNUSED13		= 0x01000000i;
const int CONTENTBIT_BODY		= 0x02000000i;	/* SOLID_BBOX/SLIDEBOX */
const int CONTENTBIT_CORPSE		= 0x04000000i;	/* SOLID_CORPSE */
const int CONTENTBIT_UNUSED14		= 0x08000000i;

const int CONTENTBIT_UNUSED15		= 0x10000000i;
const int CONTENTBIT_Q2LADDER		= 0x20000000i;	/* Q2BSP climbables */
const int CONTENTBIT_UNUSED16		= 0x40000000i;
const int CONTENTBIT_SKY		= 0x80000000i;	/* Q1BSP only! */


/* this is used for material-lookups using the external materials.txt file
 * method used in Half-Life. In that environment we have to strip any
 * prefixes and limit our material-name to 12 chars for everything to be
 * identified correctly */
string
Materials_FixName(string tex_name)
{
	dprint(sprintf("^3Materials_FixName^7: %s > ", tex_name));

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

	dprint(sprintf("%s\n", tex_name));

	return tex_name;
}
