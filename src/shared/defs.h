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

typedef entity id;

/* networking helpers */
#define NETWORKED_INT(x) int x; int x ##_net;
#define NETWORKED_FLOAT(x) float x; float x ##_net;
#define NETWORKED_VECTOR(x) vector x; vector x ##_net;
#define NETWORKED_ENT(x) entity x; entity x ##_net;
#define NETWORKED_STRING(x) string x; string x ##_net;
#define NETWORKED_BOOL(x) bool x; bool x ##_net;
#define NETWORKED_MODELINDEX(x) float x; float x ##_net;

#define NETWORKED_INT_N(x) int x ##_net;
#define NETWORKED_FLOAT_N(x) float x ##_net;
#define NETWORKED_VECTOR_N(x) vector x ##_net;
#define NETWORKED_STRING_N(x) string x ##_net;

#define PREDICTED_INT(x) int x; int x ##_net;
#define PREDICTED_FLOAT(x) float x; float x ##_net;
#define PREDICTED_VECTOR(x) vector x; vector x ##_net;
#define PREDICTED_ENT(x) entity x; entity x ##_net;
#define PREDICTED_STRING(x) string x; string x ##_net;
#define PREDICTED_BOOL(x) bool x; bool x ##_net;

#define PREDICTED_INT_N(x) int x ##_net;
#define PREDICTED_FLOAT_N(x) float x ##_net;
#define PREDICTED_VECTOR_N(x) vector x ##_net;
#define PREDICTED_STRING_N(x) string x ##_net;

#ifdef CLIENT
#define NSENTITY_READENTITY(x, y) \
	{ \
		local x x ##_e = ( x )self;\
		if (y == true) { \
			self.classname = strcat("spawnfunc_", #x); \
			callfunction(self.classname); \
		} \
		x ##_e.ReceiveEntity( y, readfloat() );\
		x ##_e.Relink();\
	}
#else

#endif

#define NETWORKED_DEFAULT(x, y) x ##_net = x = y;

#define ROLL_BACK(x) x = x ##_net;
#define SAVE_STATE(x) x ##_net = x;
#define SAVE_STATE_FIELD(x, y) x ##_net[y] = x[y];
#define ATTR_CHANGED(x) (x ##_net != x)
#define VEC_CHANGED(x,y) (x ##_net[y] != x[y])

#define STRING_SET(x) ((x != __NULL__) && (x != ""))

#ifndef MAX_AMMO_TYPES
#define MAX_AMMO_TYPES 16i
#endif

noref const float   SVC_TEMPENTITY          = 23;

#ifdef CLIENT
string __fullspawndata;
#endif

#include "global.h"
#include "cloader.h"
#include "sound.h"
#include "effects.h"
#include "math.h"

#ifdef CLIENT
#include "../gs-entbase/client/defs.h"
#else
#include "../gs-entbase/server/defs.h"
#endif

#include "NSDecal.h"

#include "../botlib/botinfo.h"
#include "sentences.h"

#include "NSIO.h"
#include "NSDict.h"
#include "NSTrigger.h"
#include "NSEntity.h"
#include "NSTimer.h"
#include "NSRenderableEntity.h"
#include "NSSurfacePropEntity.h"
#include "NSMoverEntity.h"
#include "NSPhysicsConstraint.h"
#include "NSPhysicsEntity.h"
#include "NSBrushTrigger.h"
#include "NSPointTrigger.h"
#include "NSItem.h"
#include "NSWeapon.h"
#include "NSNavAI.h"
#include "NSMonster.h"
#include "NSSquadMonster.h"
#include "NSTalkMonster.h"
#include "NSSpawnPoint.h"
#include "NSSoundScape.h"
#include "NSAttack.h"
#include "NSProjectile.h"
#include "NSSpraylogo.h"
#include "NSPortal.h"
#include "NSDebris.h"

#include "../xr/defs.h"
#include "../botlib/NSBot.h"
#include "NSClient.h"
#include "NSClientSpectator.h"
#include "NSClientPlayer.h"

#include "NSVehicle.h"

#include "materials.h"
#include "damage.h"
#include "flags.h"
#include "entities.h"
#include "events.h"
#include "flags.h"
#include "hitmesh.h"
#include "pmove.h"
#include "memory.h"
#include "platform.h"
#include "propdata.h"
#include "surfaceproperties.h"
#include "decalgroups.h"
#include "colors.h"
#include "motd.h"
#include "util.h"
#include "ammo.h"

#define BSPVER_PREREL 	28
#define BSPVER_Q1		29
#define BSPVER_HL		30
#define BSPVER_Q2		38
#define BSPVER_Q2W		69
#define BSPVER_Q3		46
#define BSPVER_RTCW		47
#define BSPVER_RBSP 	1

#define CLASSEXPORT(a,b) void a(void) { if (!isfunction(#b)) { self.classname = strcat("spawnfunc_", #b); } else { self.classname = #b; } callfunction(self.classname); }

const vector VEC_HULL_MIN = [-16,-16,-36];
const vector VEC_HULL_MAX = [16,16,36];
const vector VEC_CHULL_MIN = [-16,-16,-18];
const vector VEC_CHULL_MAX = [16,16,18];

// Actually used by input_button etc.
#define INPUT_BUTTON0 0x00000001	/* attack 1*/
#define INPUT_BUTTON2 0x00000002	/* jumping */
#define INPUT_BUTTON3 0x00000004	/* prone */
#define INPUT_BUTTON4 0x00000008	/* reload */
#define INPUT_BUTTON5 0x00000010	/* secondary */
#define INPUT_BUTTON6 0x00000020	/* use */
#define INPUT_BUTTON7 0x00000040	/* reserved */
#define INPUT_BUTTON8 0x00000080	/* crouching */

#define INPUT_PRIMARY INPUT_BUTTON0
#define INPUT_JUMP INPUT_BUTTON2
#define INPUT_PRONE INPUT_BUTTON3
#define INPUT_RELOAD INPUT_BUTTON4
#define INPUT_SECONDARY INPUT_BUTTON6
#define INPUT_USE INPUT_BUTTON5 /* This can NEVER change. Engine hard-coded. */
#define INPUT_SPRINT INPUT_BUTTON7
#define INPUT_CROUCH INPUT_BUTTON8

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

void Util_Destroy(void);
string Util_TimeToString(float fTime);
bool Util_IsTeamplay(void);
bool Util_IsPaused(void);

__wrap void
dprint(string m)
{
	if (cvar("developer") == 1)
		return prior(m);
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

#if 0
__wrap string
precache_model(string m)
{
	if not (m) {
		breakpoint();
		return "";
	}

	if (m == "") {
		breakpoint();
		return "";
	}

	return prior(m);
}
#endif

__wrap string
precache_sound(string sample)
{
	if (sample != "") /* not empty */
		if not(whichpack(strcat("sound/", sample))) { /* not present on disk */
			NSError("SFX sample %S does not exist.", sample);
			return "misc/missing.wav";
		}

	return prior(sample);
}

/* this could probably be a lot better, use this from now on so that it can be improved later */
noref float input_sequence;
float
pseudorandom()
{
	float seed = (float)input_sequence % 5.0f;
	seed += (float)input_sequence % 8.0f;
	seed += (float)input_sequence % 4.0f;
	seed += (float)input_sequence % 13.0f;
	seed += (float)input_sequence % 70.0f;

	/* like the engine its random(), never return 0, never return 1 */
	return bound(0.01, (seed) / 100.0f, 0.99f);
}

#if 0
__wrap void
WriteByte(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteChar(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteShort(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteLong(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteCoord(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteAngle(float to, float val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteString(float to, string val)
{
	breakpoint();
	prior(to, val);
}

__wrap void
WriteEntity(float to, entity val)
{
	breakpoint();
	prior(to, val);
}
#endif

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

.float identity;
.float removed;
__wrap void
remove(entity target)
{
	/* it's an NSEntity sub-class */
	if (target.identity) {
		NSEntity ent = (NSEntity)target;

		/* if we're calling remove() on it and not .Destroy()... it's being uncleanly removed! */
		if (ent.removed == 0) {
			ent.OnRemoveEntity();
			breakpoint();
			print(sprintf("^1WARNING: Entity %d of class %s uncleanly removed!\n", num_for_edict(ent), ent.classname));
			ent.removed = 1;
		}
	}

	target.removed = 0;
	prior(target);
}

__wrap void
traceline(vector v1, vector v2, float flags, entity ent)
{
#ifdef SERVER
	if (autocvar(com_showTracers, 0) == 1) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_TRACEDEBUG);
		WriteCoord(MSG_MULTICAST, v1[0]);
		WriteCoord(MSG_MULTICAST, v1[1]);
		WriteCoord(MSG_MULTICAST, v1[2]);
		WriteCoord(MSG_MULTICAST, v2[0]);
		WriteCoord(MSG_MULTICAST, v2[1]);
		WriteCoord(MSG_MULTICAST, v2[2]);
		msg_entity = world;
		multicast(v1, MULTICAST_PVS_R);
	}
#endif

#ifdef CLIENT
	// TODO
#endif
	prior(v1, v2, flags, ent);
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

#ifdef SERVER
string Skill_GetStringValue(string, string);
#endif

string
unpackStringCommand(string commandString)
{
#ifdef SERVER
	/* is this supposed to be read from a skill cvar? */
	if (substring(commandString, 0, 6) == "skill:") {
		return Skill_GetStringValue(substring(commandString, 6, -1), "");
	}
	/* is this supposed to be read from a skill cvar? */
	if (substring(commandString, 0, 5) == "cvar:") {
		return cvar_string(substring(commandString, 5, -1), "");
	}
#endif

	return Constants_LookUp(commandString, commandString);
}

#ifdef NO_LEGACY
void
readcmd(string foo)
{
	localcmd(foo);
}
#else
void(string cmd) readcmd = #0:readcmd;
#endif

/* This is required because people who use Hammer do awful things
   to get their models to update. We get a multitude of juicy
   hacks and symbols that Half-Life's engine strips and now we have to
   replicate this behaviour. Be thankful this is not done in-engine for
   every game/mod ever.
*/
string Util_FixModel(string mdl)
{
	if (!mdl) {
		return "";
	}

	int c = tokenizebyseparator(mdl, "/", "\\ ", "!");
	string newpath = "";

	for (int i = 0; i < c; i++) {
		newpath = sprintf("%s/%s", newpath, argv(i));
	}

	/* Kill the first / */
	newpath = substring(newpath, 1, strlen(newpath)-1);

	/* Now we need to fix \/ because I hate people */
	c = tokenizebyseparator(newpath, "\\/");
	mdl = "";
	for (int i = 0; i < c; i++) {
		mdl = sprintf("%s/%s", mdl, argv(i));
	}
	/* Kill the first / again */
	mdl = substring(mdl, 1, strlen(mdl)-1);

	if (substring(mdl, 0, 1) == "/")
		mdl = substring(mdl, 1, -1);

	return mdl;
}

/** Returns a string (usually filename) with only the file extension
    at the end replaced with a given, new extension. */
string
Util_ChangeExtension(string baseString, string newExtension)
{
	float stringOffset = 0;
	string tempString = "";
	float foundOffset = 0;
	
	while ((tempString = substring(baseString, stringOffset, 1))) {
		if (tempString == ".")
			foundOffset = stringOffset;
		if (tempString == "")
			break;
		if not (tempString)
			break;

		stringOffset++;
	}

	return strcat(substring(baseString, 0, foundOffset), ".", newExtension);
}

bool
Util_IsSingleplayer(void)
{
#ifdef SERVER
	/* playerslots 1 is always singleplayer */
	if (cvar("sv_playerslots") == 1)
		return true;

	/* only when coop is 1, only in multiplayer */
	if (cvar("coop") == 1 && cvar("sv_playerslots") > 1)
		return true;
#endif

	/* else we're multiplayer */
	return false;
}

float
crandom(void)
{
	return ((random() - 0.5f) * 2.0f);
}

string
dirname(string input)
{
	if (!input) {
		return "";
	}

	int c = tokenizebyseparator(input, "/", "\\ ", "!");
	string newpath = "";

	for (int i = 0; i < (c-1); i++) {
		newpath = sprintf("%s/%s", newpath, argv(i));
	}

	/* Kill the first / */
	newpath = substring(newpath, 1, strlen(newpath)-1);

	return newpath;
}

string
textfile_to_string(string filename)
{
	string fileContents = __NULL__;

	filestream fileHandle = fopen(filename, FILE_READ);
	string temp;

	if (fileHandle != -1) {
		while ((temp = fgets(fileHandle))) {
			fileContents = strcat(fileContents, temp, "\n");
		}
	} else {
		fileContents = __NULL__;
	}

	return fileContents;
}

/* moved from src/botlib/route.qc */
/* Get's a velocity vector with which we can successfully jump from one place to another */
vector
Route_GetJumpVelocity(vector vecFrom, vector vecTo, float flGravMod)
{
#if 1
	float flHeight, flGravity, flTime, flDistance, flDir;
	vector vecJump = [0,0,0];

	if (flGravMod <= 0.0)
		flGravMod = 1.0f;

	flGravity = serverkeyfloat("phy_gravity") * flGravMod;
	flHeight = vecTo[2] - vecFrom[2];

	/* this may not be a much verticality to this jump, use distance instead */
	if (flHeight <= 0) {
		flHeight = vlen(vecTo - vecFrom);
		flTime = flHeight / flGravity;
	} else {
		flTime = sqrt(flHeight / (flGravity * 0.5f));
		if (flTime <= 0) {
			return [0,0,0];
		}
	}

	vecJump = vecTo - vecFrom;
	vecJump[2] = 0;
	flDistance = vlen(normalize(vecJump));

	flDir = flDistance / flTime;
	vecJump *= flDir;
	vecJump[2] = flTime * flGravity;
#else
	vector vecJump = [0,0,0];
	float flDist = vlen(vecTo - vecFrom);
	makevectors(vectoangles(vecTo - vecFrom));
	vecJump = v_forward * flDist;
	vecJump[2] = 280;
#endif
	return vecJump;
}

bool
fileExists(string filePath)
{
	if (filePath != "") /* not empty */
		if not(whichpack(filePath)) /* not present on disk */
			return false;

	return true;
}

void
DebugBox(vector absPos, vector minSize, vector maxSize, vector boxColor, float boxAlpha)
{
	vector a, b, c, d;
	vector w, x, y, z;

	a[0] = absPos[0] + minSize[0];
	a[1] = absPos[1] + maxSize[1];

	b[0] = absPos[0] + maxSize[0];
	b[1] = absPos[1] + maxSize[1];

	c[0] = absPos[0] + maxSize[0];
	c[1] = absPos[1] + minSize[1];

	d[0] = absPos[0] + minSize[0];
	d[1] = absPos[1] + minSize[1];

	a[2] = absPos[2] + maxSize[2];
	c[2] = absPos[2] + maxSize[2];
	d[2] = absPos[2] + maxSize[2];
	b[2] = absPos[2] + maxSize[2];

	w = a;
	x = b;
	y = c;
	z = d;

	w[2] = absPos[2] + minSize[2];
	x[2] = absPos[2] + minSize[2];
	y[2] = absPos[2] + minSize[2];
	z[2] = absPos[2] + minSize[2];
	
	/* top */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(a, [1,1], boxColor, boxAlpha);
	R_PolygonVertex(b, [0,1], boxColor, boxAlpha);
	R_PolygonVertex(c, [0,0], boxColor, boxAlpha);
	R_PolygonVertex(d, [1,0], boxColor, boxAlpha);
	R_EndPolygon();

	/* front */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(d, [1,1], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(c, [0,1], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(y, [0,0], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(z, [1,0], boxColor * 0.9f, boxAlpha);
	R_EndPolygon();

	/* back */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(w, [1,1], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(x, [0,1], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(b, [0,0], boxColor * 0.9f, boxAlpha);
	R_PolygonVertex(a, [1,0], boxColor * 0.9f, boxAlpha);
	R_EndPolygon();

	/* left */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(a, [1,1], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(d, [0,1], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(z, [0,0], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(w, [1,0], boxColor * 0.8f, boxAlpha);
	R_EndPolygon();

	/* right */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(c, [1,1], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(b, [0,1], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(x, [0,0], boxColor * 0.8f, boxAlpha);
	R_PolygonVertex(y, [1,0], boxColor * 0.8f, boxAlpha);
	R_EndPolygon();

	/* bottom */
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(z, [1,1], boxColor, boxAlpha);
	R_PolygonVertex(y, [0,1], boxColor, boxAlpha);
	R_PolygonVertex(x, [0,0], boxColor, boxAlpha);
	R_PolygonVertex(w, [1,0], boxColor, boxAlpha);
	R_EndPolygon();
}

/* doxygen definitions */

/** @defgroup client Client Game
 *  Part of the client-side progs (`csprogs.dat`).
 */

/** @defgroup server Server Game
 *  Part of the server-side progs (`progs.dat`).
 */

/** @defgroup shared Shared Game
 *  Part of both client and server-side progs.
 */

/** @defgroup menu Menu Game
 *  Part of the menu progs (`menu.dat`).
 */

/** @defgroup multiprogs Multi-Progs, Plugin APIs
 *  @ingroup server
 *  APIs that are accessible via multiprogs.
 */

/** @defgroup vgui VGUI
 *  @ingroup client
 *  @ingroup menu
 *
 *  Our very own, very _true_ graphical user interface.
 */

/** @defgroup sound Sound System
Classes and APIs that interact with the sound system.

By default we assume the engine is talking to **OpenAL**,
either **OpenAL-Soft** or a driver talking to [Creative](http://www.creative.com/)
hardware with native support for Environmental Extensions.

If not available, most new features will be unavailable.
*/

/** @defgroup nav Navigation System
 *  @ingroup server
 *  APIs to interact with the navigation system powering AI entities.
 */

/** @defgroup baseclass Base Classes
 *  @ingroup entities
 *  Base Classes powering all sorts of [entities](@ref entities).
 */

/** @defgroup brushentity Brush Entities
 *  @ingroup entities
 *  Entity class that expects to be used with brush models.
 *
 *  Brush models are commonly sub-models within a level file,
 *  however they can also be loaded from a separate external file.
 *
 *  If an entity its model starts with and asterisk (*) and ends
 *  with a numer right after, it usually refers to a sub-model
 *  within the current world level.
 *
 *  Due to their simple visual complexity they are mostly
 *  used for primitive geometry, triggers, volumes.
 *
 *  Mainly used for MOVETYPE_PUSH entities of variable
 *  size and volume - even within a single class.
 */

/** @defgroup pointentity Point Entities
 *  @ingroup entities
 *  Point entities are the most common types of entities.
 *
 *  They exist at a single point in 3D-space.
 *  Generally every class of point-entity is of equal
 *  size and volume, unlike [brush-based entities](@ref brushentity).
 *  Generally used for moving, or non moving objects
 *  that interact with the world.
 */
