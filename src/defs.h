/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/* Those are constant for HL BSP and CANNOT be changed.
 * Blame Valve for purchasing a Quake II license but not
 * scrapping hull sizes for their .bsp format... */
const vector VEC_HULL_MIN = [-16,-16,-36];
const vector VEC_HULL_MAX = [16,16,36];
const vector VEC_CHULL_MIN = [-16,-16,-18];
const vector VEC_CHULL_MAX = [16,16,18];

/* Counter-Strike players are hunched over a little bit */
#ifdef CSTRIKE
const vector VEC_PLAYER_VIEWPOS =  [0,0,20];
const vector VEC_PLAYER_CVIEWPOS = [0,0,12];
#else
const vector VEC_PLAYER_VIEWPOS = [0,0,24];
const vector VEC_PLAYER_CVIEWPOS = [0,0,12];
#endif

// Actually used by input_button etc.
#define INPUT_BUTTON0 0x00000001
#define INPUT_BUTTON2 0x00000002
#define INPUT_BUTTON3 0x00000004
#define INPUT_BUTTON4 0x00000008
#define INPUT_BUTTON5 0x00000010
#define INPUT_BUTTON6 0x00000020
#define INPUT_BUTTON7 0x00000040
#define INPUT_BUTTON8 0x00000080

// Engine reserved flags
#define FL_FLY			(1<<0)
#define FL_SWIM			(1<<1)
#define FL_GLIMPSE		(1<<2)
#define FL_CLIENT		(1<<3)
#define FL_INWATER		(1<<4)
#define FL_MONSTER		(1<<5)
#define FL_GODMODE		(1<<6)
#define FL_NOTARGET		(1<<7)
#define FL_ITEM			(1<<8)
#define FL_ONGROUND		(1<<9)
#define FL_PARTIALGROUND	(1<<10)
#define FL_WATERJUMP		(1<<11)
#define FL_JUMPRELEASED		(1<<12)
#define FL_FINDABLE_NONSOLID	(1<<14)
#define FLQW_LAGGEDMOVE		(1<<16)

// FreeCS flags
#define FL_FLASHLIGHT		(1<<17)
#define FL_REMOVEME		(1<<18)
#define FL_CROUCHING 		(1<<19)
#define FL_SEMI_TOGGLED		(1<<20)
#define FL_FROZEN 		(1<<21)
#define FL_ONLADDER		(1<<13)

#define clamp(d,min,max) bound(min,d,max)

.float jumptime;
.float teleport_time;

void* memrealloc( __variant *oldptr, int elementsize, int oldelements, int newelements )
{
	void *n = memalloc( elementsize * newelements );
	memcpy( n, oldptr, elementsize * min( oldelements, newelements ) );
	memfree( oldptr );
	return n;
}

void Empty(void)
{
	
}
