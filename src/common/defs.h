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

#define bool float
#define true 1
#define false 0

/** @group common Common Functions
 *  @{
 */

var bool autocvar_g_logTimestamps = false;

typedef entity id;
typedef float musictrack_t;

typedef enum
{
	LOGLEVEL_NONE,
	LOGLEVEL_ERRORS,
	LOGLEVEL_WARNINGS,
	LOGLEVEL_DEBUG,
} logLevel_t;

#define LOGLEVEL_DEFAULT LOGLEVEL_WARNINGS
var logLevel_t autocvar_g_logLevel = LOGLEVEL_DEFAULT;

#define printf(...) print(sprintf(__VA_ARGS__))

#ifdef DOXYGEN
/** Doxygen doesn't know what enumflags (aka bitfields) are, used as e.g. */
#define enumflags enum
#endif

#define ICN_SIZE 8

string
imageToConsole(string imageName, int imgSize, string toolTip)
{
	return sprintf("^[\\img\\%s\\s\\%i\\tip\\%s^]", imageName, imgSize, toolTip);
}

#define CG_LOG			imageToConsole("gfx/icon16/monitor", ICN_SIZE, "Client Game Log")
#define CG_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "Client Game Warning")
#define CG_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "Client Game Error")

#define SV_LOG			imageToConsole("gfx/icon16/server", ICN_SIZE, "Server Game Log")
#define SV_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "Server Game Warning")
#define SV_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "Server Game Error")

#define UI_LOG			imageToConsole("gfx/icon16/picture", ICN_SIZE, "Menu Game Log")
#define UI_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "Menu Game Warning")
#define UI_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "Menu Game Error")

void
_ncLog(string msg)
{
#ifdef CLIENT
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", CG_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", CG_LOG, msg));
#endif
#ifdef SERVER
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", SV_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", SV_LOG, msg));
#endif
#ifdef MENU
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", UI_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", UI_LOG, msg));
#endif
}

void
_ncError(string functionName, string msg)
{
#ifdef CLIENT
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^7: %s\n", CG_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^7: %s\n", CG_ERROR, functionName, msg));
#endif
#ifdef SERVER
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^7: %s\n", SV_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^7: %s\n", SV_ERROR, functionName, msg));
#endif
#ifdef MENU
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^7: %s\n", UI_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^7: %s\n", UI_ERROR, functionName, msg));
#endif
}

void
_ncWarning(string functionName, string msg)
{
#ifdef CLIENT
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^7: %s\n", CG_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^7: %s\n", CG_WARNING, functionName, msg));
#endif
#ifdef SERVER
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^7: %s\n", SV_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^7: %s\n", SV_WARNING, functionName, msg));
#endif
#ifdef MENU
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^7: %s\n", UI_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^7: %s\n", UI_WARNING, functionName, msg));
#endif
}

void
_NSAssert(bool condition, string function, string descr)
{
#ifdef CLIENT
	if (!condition) {
		print(strcat(CG_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
		breakpoint();
	}
#endif
#ifdef SERVER
	if (!condition) {
		print(strcat(SV_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
		breakpoint();
	}
#endif
#ifdef MENU
	if (!condition) {
		print(strcat(UI_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
	}
#endif
}

/** Logs an message, with timestamp.
	 The console variable `g_logLevel` has to be `3` or higher for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define ncLog(...) if (autocvar_g_logLevel >= LOGLEVEL_DEBUG) _ncLog(sprintf(__VA_ARGS__))

/** Logs an error message, with timestamp.
	 The console variable `g_logLevel` has to be `1` or higher for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define ncError(...) if (autocvar_g_logLevel >= LOGLEVEL_ERRORS) _ncError(__FUNC__, sprintf(__VA_ARGS__))

/** Logs a warning message, with timestamp.
	 The console variable `g_logLevel` has to be `2` or higher for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define ncWarning(...) if (autocvar_g_logLevel >= LOGLEVEL_WARNINGS) _ncWarning(__FUNC__, sprintf(__VA_ARGS__))

/** Generates an assertion, if a given condition is false.
	 The console variable `g_logLevel` has to be `1` or higher for them to be visible.

@param condition is the expression to be evaluated.
@param description(...) contains a formatted string containing an error description. */

#define NSAssert(condition, ...) if (autocvar_g_logLevel >= LOGLEVEL_ERRORS) _NSAssert(condition, __FUNC__, sprintf(__VA_ARGS__))

typedef enumflags
{
       SEARCH_INSENSITIVE,	/**< Attempt to do a case-insensitive search (slower) */
       SEARCH_FULLPACKAGE,	/**< Package names include the game directory as a prefix */
       SEARCH_ALLOWDUPES,	/**< Do not attempt to remove duplicate results (so you can search through multiple archives) */
       SEARCH_FORCESEARCH,	/**< Search a given game directory even if it's not mounted */
       SEARCH_MULTISEARCH,	/**< When set, separating search queries with `:` will allow for multiple queries in one string */
       SEARCH_NAMESORT		/**< Sort the results alphabetically (slower) */
} searchFlags_t;

const vector g_vec_null = [0.0f, 0.0f, 0.0f];

/* the console needs some attention too. */
var float g_initTime;

void
InitPrint(string functionName)
{
	int chars = 51i;
	int charsLeft;
	int charExtra;
	string sideLeft = "";
	string sideRight = "";

	if (functionName == __NULL__) {
		ncLog("---------------------------------------------------");
		return;
	}

	/* word and padding */
	chars = chars - (int)strlen(functionName) - 2i;
	charsLeft = chars / 2i;
	charExtra = chars % 2i;

	for (int i = 0i; i < charsLeft; i++)
		sideLeft = strcat(sideLeft,"-");

	for (int i = 0i; i < (charsLeft + charExtra); i++) {
		sideRight = strcat(sideRight,"-");
	}

	ncLog( "%s %s %s", sideLeft, functionName, sideRight);
}

var string g_lastInitFunc;
void
_InitStart(string functionName)
{
	if (g_initTime != 0)
		error(sprintf("Called InitStart() without InitEnd()ing %s!", g_lastInitFunc));

	InitPrint(functionName);
	g_lastInitFunc = functionName;
	g_initTime = gettime(1);
}

#define InitStart() _InitStart(__FUNC__)

void
_InitEnd(void)
{
	float endTime = gettime(1);
	ncLog("loaded in %.1f seconds", (endTime - g_initTime));
	ncLog("---------------------------------------------------");
	g_initTime = 0;
}

#define InitEnd() _InitEnd()

/** Doesn't work yet. Compiler bug (!) */
#define entity_def(x, ...) const string x[] = { __VA_ARGS__ }

/** Calls a function (with parameters) in a new thread. */
#define thread(x) if (fork()) { x; abort(); }

#define STRING_SET(x) ((x != __NULL__) && (x != ""))

bool
fileExists(string filePath)
{
	if (filePath != "") /* not empty */
		if not(whichpack(filePath)) /* not present on disk */
			return false;

	return true;
}
string
Util_ExtensionFromString(string inputString)
{
	int modelNameLength = strlen(inputString);
	return substring(inputString, modelNameLength - 3, modelNameLength);
}

void
CallSpawnfuncByName(entity target, string className)
{
	entity oldSelf = self;
	string spawnClass = strcat("spawnfunc_", className);
	self = target;
	callfunction(spawnClass);
	self = oldSelf;
}

.string spawnclass;

/** @} */ // end of common

#include "c_math.h"
#include "c_math_vector.h"
#include "c_memory.h"
#include "c_platform.h"
#include "c_colors.h"
#include "c_materials.h"
#include "c_teams.h"
#include "c_events.h"
#include "c_flags.h"
