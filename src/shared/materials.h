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

/** @defgroup materials Materials
    @brief Material property lookup functions, with support for different level formats.
    @ingroup shared

@{
*/

/** Returns the [SurfData](@ref surfdata) assigned to the texture. */
string Materials_SurfDataForTexture(string);

/** Initializes the material -> surfdata look-up table. */
void Materials_Init(void);

/** @} */ // end of materials

#define SURF_NODAMAGE	0x1i		/**< never give falling damage */
#define SURF_SLICK		0x2i		/**<  effects game physics */
#define SURF_SKY		0x4i		/**<  lighting from environment map */
#define SURF_LADDER		0x8i		/**<  climb this surface */
#define SURF_NOIMPACT	0x10i		/**<  don't make missile explosions */
#define SURF_NOMARKS	0x20i		/**<  don't leave missile marks */
#define SURF_Q3FLESH	0x40i		/**<  make flesh sounds and effects */
#define SURF_NODRAW		0x80i		/**<  don't generate a drawsurface at all */
#define SURF_HINT		0x100i		/**<  make a primary bsp splitter */
#define SURF_SKIP		0x200i		/**<  completely ignore, allowing non-closed brushes */
#define SURF_NOLIGHTMAP		0x400i		/**<  surface doesn't need a lightmap */
#define SURF_POINTLIGHT		0x800i		/**<  generate lighting info at vertexes */
#define SURF_METALSTEPS		0x1000i		/**<  clanking footsteps */
#define SURF_NOSTEPS		0x2000i		/**<  no footstep sounds */
#define SURF_NONSOLID		0x4000i		/**<  don't collide against curves with this set */
#define SURF_LIGHTFILTER	0x8000i		/**<  act as a light filter during q3map -light */
#define SURF_ALPHASHADOW	0x10000i	/**<  do per-pixel light shadow casting in q3map */
#define SURF_NODLIGHT		0x20000i	/**<  don't dlight even if solid (solid lava, skies) */
#define SURF_DUST			0x40000i	/**<  leave a dust trail when walking on this surface */

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
