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

/* other notes:

	in The Wastes (2003) 'I' is sand, 'U' is plaster,
	'R' is rust.
*/

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

void Footsteps_Init(void);
void Footsteps_HLBSP(base_player target);
void Footsteps_VVBSP(base_player target);
void Footsteps_Default(base_player target);
void Footsteps_Update(void);
