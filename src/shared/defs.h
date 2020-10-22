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

#include "player.h"
#include "damage.h"
#include "flags.h"
#include "hitmesh.h"
#include "entities.h"
#include "events.h"
#include "flags.h"
#include "hitmesh.h"
#include "materials.h"
#include "math.h"
#include "sound.h"

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

/* sendflags */
#define UPDATE_ALL				16777215

#define clamp(d,min,max) bound(min,d,max)

.float jumptime;
.float teleport_time;
.vector basevelocity;
.float gflags;

void*
memrealloc(__variant *oldptr, int elementsize, int oldelements, int newelements)
{
	void *n = memalloc(elementsize * newelements);
	memcpy(n, oldptr, elementsize * min(oldelements, newelements));
	memfree(oldptr);
	return n;
}

__wrap __variant*
memalloc(int size)
{
	return prior(size);
}

void
Empty(void)
{
	
}

void
Util_Destroy(void)
{
	remove(self);
}

__wrap void
dprint(string m)
{
	if (cvar("developer") == 1)
		return prior(m);
}

__wrap string
precache_model(string m)
{
#ifdef CLIENT
	dprint(sprintf("^3Client precaching model ^7%s\n", m));
#else
	dprint(sprintf("^3Server precaching model ^7%s\n", m));
#endif
	return prior(m);
}

/* info print */
void
iprint(string m)
{
	print(sprintf("^Ue080^Ue081^Ue081^Ue081^Ue081^Ue081^Ue081 %s ^Ue081^Ue081^Ue081^Ue081^Ue081^Ue081^Ue082\n", m));
}
