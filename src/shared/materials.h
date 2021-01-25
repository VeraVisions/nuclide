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
enum
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
	IMPACT_SLOSH,
	IMPACT_SNOW,
	IMPACT_TILE,
	IMPACT_VENT,
	IMPACT_WOOD
};


/* TW/NEXT specific game flags */

/* q3 bsp base flags */
#define SURF_NODAMAGE		0x1i		// never give falling damage
#define SURF_SLICK			0x2i		// effects game physics
#define SURF_SKY			0x4i		// lighting from environment map
#define SURF_LADDER			0x8i		// climb this surface
#define SURF_NOIMPACT		0x10i		// don't make missile explosions
#define SURF_NOMARKS		0x20i		// don't leave missile marks
#define SURF_Q3FLESH		0x40i		// make flesh sounds and effects
#define SURF_NODRAW			0x80i		// don't generate a drawsurface at all
#define SURF_HINT			0x100i		// make a primary bsp splitter
#define SURF_SKIP			0x200i		// completely ignore, allowing non-closed brushes
#define SURF_NOLIGHTMAP		0x400i		// surface doesn't need a lightmap
#define SURF_POINTLIGHT		0x800i		// generate lighting info at vertexes
#define SURF_METALSTEPS		0x1000i		// clanking footsteps
#define SURF_NOSTEPS		0x2000i		// no footstep sounds
#define SURF_NONSOLID		0x4000i		// don't collide against curves with this set
#define SURF_LIGHTFILTER	0x8000i		// act as a light filter during q3map -light
#define SURF_ALPHASHADOW	0x10000i	// do per-pixel light shadow casting in q3map
#define SURF_NODLIGHT		0x20000i	// don't dlight even if solid (solid lava, skies)
#define SURF_DUST			0x40000i	// leave a dust trail when walking on this surface

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
#define SURF_MASK			0x0FFFFFFFi
#define SURF_ALIEN			0x10000000i
#define SURF_BLOODYFLESH	0x20000000i
#define SURF_FOLIAGE		0x30000000i
#define SURF_COMPUTER		0x40000000i
#define SURF_DIRT			0x50000000i
#define SURF_VENT			0x60000000i
#define SURF_GRATE			0x70000000i
#define SURF_METAL			0x80000000i
#define SURF_GLASS			0x90000000i
#define SURF_SAND			0xA0000000i
#define SURF_SLOSH			0xB0000000i
#define SURF_SNOW			0xC0000000i
#define SURF_TILE			0xD0000000i
#define SURF_WOOD			0xE0000000i
#define SURF_CONCRETE		0xF0000000i

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

	/* limit to 12 chars! */
	tex_name = substring(tex_name, 0, 12);

	dprint(sprintf("%s\n", tex_name));

	return tex_name;
}
