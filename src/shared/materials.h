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
	IMPACT_GLASS,
	IMPACT_WOOD,
	IMPACT_METAL,
	IMPACT_FLESH,
	IMPACT_ROCK
};


/* TW/NEXT specific game flags */

/* q3 bsp base flags */
#define SURF_NODAMAGE		0x1i		// never give falling damage
#define SURF_SLICK			0x2i		// effects game physics
#define SURF_SKY			0x4i		// lighting from environment map
#define SURF_LADDER			0x8i		// climb this surface
#define SURF_NOIMPACT		0x10i		// don't make missile explosions
#define SURF_NOMARKS		0x20i		// don't leave missile marks
#define SURF_FLESH			0x40i		// make flesh sounds and effects
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

// behaviour surfaceflags
#define SURF_LEAKSTEAM		0x80000i	/* surface shoots steam when hit */
#define SURF_LEAKWATER		0x100000i	/* surface sprays water when hit */

// material surfaceflags
#define SURF_MASK		0x0FFFFFFFi
#define SURF_ALIEN		0x10000000i
#define SURF_FLESH		0x20000000i
#define SURF_FOLIAGE	0x30000000i
#define SURF_COMPUTER	0x40000000i
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
#define SURF_CONCRETE	0xF0000000i
