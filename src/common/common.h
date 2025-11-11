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

#define RULE_LOG		imageToConsole("gfx/icon16/script_go", ICN_SIZE, "RuleC Log")
#define RULE_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "RuleC Warning")
#define RULE_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "RuleC Error")

#define MAP_LOG			imageToConsole("gfx/icon16/map_go", ICN_SIZE, "MapC Log")
#define MAP_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "MapC Warning")
#define MAP_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "MapC Error")

#define HUD_LOG			imageToConsole("gfx/icon16/monitor_go", ICN_SIZE, "HudC Log")
#define HUD_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "HudC Warning")
#define HUD_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "HudC Error")

#define ADDON_LOG		imageToConsole("gfx/icon16/plugin_go", ICN_SIZE, "AddonC Log")
#define ADDON_WARNING		imageToConsole("gfx/icon16/error", ICN_SIZE, "AddonC Warning")
#define ADDON_ERROR		imageToConsole("gfx/icon16/exclamation", ICN_SIZE, "AddonC Error")

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
#ifdef RULEC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", RULE_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", RULE_LOG, msg));
#endif
#ifdef MAPC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", MAP_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", MAP_LOG, msg));
#endif
#ifdef HUDC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", HUD_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", HUD_LOG, msg));
#endif
#ifdef ADDONC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^7%s\n", ADDON_LOG, time, msg));
	else
		print(sprintf("%s ^7%s\n", ADDON_LOG, msg));
#endif
}

void
_ncError(string functionName, string msg)
{
#ifdef CLIENT
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", CG_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", CG_ERROR, functionName, msg));
#endif
#ifdef SERVER
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", SV_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", SV_ERROR, functionName, msg));
#endif
#ifdef MENU
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", UI_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", UI_ERROR, functionName, msg));
#endif
#ifdef RULEC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", RULE_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", RULE_ERROR, functionName, msg));
#endif
#ifdef MAPC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", MAP_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", MAP_ERROR, functionName, msg));
#endif
#ifdef HUDC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", HUD_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", HUD_ERROR, functionName, msg));
#endif
#ifdef ADDONC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^1%s^1: %s\n", ADDON_ERROR, time, functionName, msg));
	else
		print(sprintf("%s ^1%s^1: %s\n", ADDON_ERROR, functionName, msg));
#endif
}

void
_ncWarning(string functionName, string msg)
{
#ifdef CLIENT
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", CG_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", CG_WARNING, functionName, msg));
#endif
#ifdef SERVER
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", SV_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", SV_WARNING, functionName, msg));
#endif
#ifdef MENU
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", UI_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", UI_WARNING, functionName, msg));
#endif
#ifdef RULEC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", RULE_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", RULE_WARNING, functionName, msg));
#endif
#ifdef MAPC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", MAP_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", MAP_WARNING, functionName, msg));
#endif
#ifdef HUDC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", HUD_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", HUD_WARNING, functionName, msg));
#endif
#ifdef ADDONC
	if (autocvar_g_logTimestamps)
		print(sprintf("%s ^9%f ^3%s^1: %s\n", ADDON_WARNING, time, functionName, msg));
	else
		print(sprintf("%s ^3%s^1: %s\n", ADDON_WARNING, functionName, msg));
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
#ifdef RULEC
	if (!condition) {
		print(strcat(RULE_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
	}
#endif
#ifdef MAPC
	if (!condition) {
		print(strcat(MAP_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
	}
#endif
#ifdef HUDC
	if (!condition) {
		print(strcat(HUD_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
	}
#endif
#ifdef ADDONC
	if (!condition) {
		print(strcat(ADDON_ERROR, " ^1Assertion failed in ", function, ", reason: ", descr, "\n"));
	}
#endif
}

/** Logs an message, with timestamp.
	 The console variable `g_logLevel` has to be `3` or higher for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define ncLog(...) if (autocvar_g_logLevel >= LOGLEVEL_DEBUG) _ncLog(sprintf(__VA_ARGS__))

/** Logs an message, with timestamp.
	 The console variable `g_logLevel` has to be `3` or higher for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define ncLogAlways(...) _ncLog(sprintf(__VA_ARGS__))

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

	ncLogAlways( "%s %s %s", sideLeft, functionName, sideRight);
}

var string g_lastInitFunc;
void
_InitStart(string functionName)
{
	InitPrint(functionName);
}

#define InitStart() float local_initTime = gettime(1); _InitStart(__FUNC__)

void
_InitEnd(float oldTime, string functionName)
{
	float endTime = gettime(1);
	ncLogAlways("%s loaded in %.1f seconds", functionName, (endTime - oldTime));
	ncLogAlways("---------------------------------------------------");
	g_initTime = 0;
}

#define InitEnd() _InitEnd(local_initTime, __FUNC__)

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
fileExtensionFromString(string inputString)
{
	int modelNameLength = strlen(inputString);
	return substring(inputString, modelNameLength - 3, -1);
}

#define Util_ExtensionFromString fileExtensionFromString

bool
wordInString(string fullString, string wordToFind)
{
	int wordCount = tokenize(fullString);

	for (int i = 0; i < wordCount; i++) {
		if (wordToFind == argv(i)) {
			return (true);
		}
	}

	return (false);
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
.float team_info;

/** @} */ // end of common
