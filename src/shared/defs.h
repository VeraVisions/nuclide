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

#include "sound.h"

#ifdef CLIENT
#include "../gs-entbase/client/defs.h"
#else
#include "../gs-entbase/server/defs.h"
#endif

#include "../gs-entbase/shared/baseentity.h"
#include "client.h"
#include "player.h"
#include "damage.h"
#include "flags.h"
#include "entities.h"
#include "events.h"
#include "flags.h"
#include "hitmesh.h"
#include "materials.h"
#include "math.h"
#include "pmove.h"
#include "memory.h"
#include "spectator.h"
#include "platform.h"
#include "propdata.h"
#include "surfaceproperties.h"
#include "vehicles.h"
#include "colors.h"

#define BSPVER_PREREL 	28
#define BSPVER_Q1		29
#define BSPVER_HL		30
#define BSPVER_Q2		38
#define BSPVER_Q2W		69
#define BSPVER_Q3		46
#define BSPVER_RTCW		47
#define BSPVER_RBSP 	1

#define CLASSEXPORT(classname,classa) void classname(void) { spawnfunc_##classa(); }

#define printf(x, ...) print(sprintf(x, ...))

const vector VEC_HULL_MIN = [-16,-16,-36];
const vector VEC_HULL_MAX = [16,16,36];
const vector VEC_CHULL_MIN = [-16,-16,-18];
const vector VEC_CHULL_MAX = [16,16,18];

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

enumflags
{
	SEARCH_INSENSITIVE,
	SEARCH_FULLPACKAGE,
	SEARCH_ALLOWDUPES,
	SEARCH_FORCESEARCH,
	SEARCH_MULTISEARCH,
	SEARCH_NAMESORT
};

.float jumptime;
.float teleport_time;
.vector basevelocity;
.float gflags;

void
Empty(void)
{
	
}

void
Util_Destroy(void)
{
	remove(self);
}

string
Util_TimeToString(float fTime)
{
	fTime = rint(fTime);

	switch (fTime) {
		case 0: return "less than one";
		case 1: return "one";
		case 2: return "two";
		case 3: return "three";
		case 4: return "four";
		case 5: return "five";
		case 6: return "six";
		case 7: return "seven";
		case 8: return "eight";
		case 9: return "nine";
		case 10: return "ten";
		default: return "over ten";
	}
}

__wrap void
dprint(string m)
{
	if (cvar("developer") == 1)
		return prior(m);
}

/* info print */
void
iprint(string m)
{
	print(sprintf("^Ue080^Ue081^Ue081^Ue081^Ue081^Ue081^Ue081 %s ^Ue081^Ue081^Ue081^Ue081^Ue081^Ue081^Ue082\n", m));
}

void
crossprint(string m)
{
#ifdef CLIENT
	print(strcat("CLIENT: ", m));
#else
	print(strcat("SERVER: ", m));
#endif
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

/* this could probably be a lot better, use this from now on so that it can be improved later */
noref float input_sequence;
float
pseudorandom()
{
	float seed = (float)input_sequence % 5;
	seed += (float)input_sequence % 8;
	seed += (float)input_sequence % 4;
	seed += (float)input_sequence % 13;
	seed += (float)input_sequence % 70;

	/* like the engine its random(), never return 0, never return 1 */
	return bound(0.01, (seed) / 100.0f, 0.99f);
}

__wrap void
setmodel(entity ent, string mname)
{
	if (mname != "") /* not empty */
	if (substring(mname, 0, 1) != "*") /* not a brush */
		if not(whichpack(mname)) /* not present on disk */
			return prior(ent, "models/error.vvm");

	return prior(ent, mname);
}

__wrap __variant*
memalloc(int size)
{
#if 0
	if (size > 55000)
		breakpoint();

	print(sprintf("memalloc: %i\n", size));
#endif
	return prior(size);
}

void
setorigin_safe(entity target, vector testorg)
{

	for (int i = 0; i < 16; i++) {
		tracebox(testorg, target.mins, target.maxs, testorg, MOVE_NORMAL, target);

		if (!trace_startsolid) {
			break;
		}

		testorg[2] += 1.0;
	}

	setorigin(target, testorg);
}
