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

var bool autocvar_g_developer = false;
var bool autocvar_g_developerTimestamps = false;

#define printf(...) print(sprintf(__VA_ARGS__))

#ifdef DOXYGEN
/** Doxygen doesn't know what enumflags (aka bitfields) are, used as e.g. */
#define enumflags enum
#endif

void
_NSLog(string msg)
{
	if (autocvar_g_developerTimestamps)
		print(sprintf("^9%f ^7%s\n", time, msg));
	else
		print(sprintf("^7%s\n", msg));
}

void
_NSError(string functionName, string msg)
{
	if (autocvar_g_developerTimestamps)
		print(sprintf("^9%f ^1%s^7: %s\n", time, functionName, msg));
	else
		print(sprintf("^1%s^7: %s\n", functionName, msg));
}

void
_NSWarning(string functionName, string msg)
{
	if (autocvar_g_developerTimestamps)
		print(sprintf("^9%f ^3%s^7: %s\n", time, functionName, msg));
	else
		print(sprintf("^3%s^7: %s\n", functionName, msg));
}

void
_NSAssert(bool condition, string function, string descr)
{
	if (!condition) {
		print(strcat("^1Assertion failed in ", function, ", reason: ", descr, "\n"));
#ifndef MENU
		breakpoint();
#endif
	}
}

/** Logs an message, with timestamp.
	 The console variable `g_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define NSLog(...) if (autocvar_g_developer) _NSLog(sprintf(__VA_ARGS__))

/** Logs an error message, with timestamp.
	 The console variable `g_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define NSError(...) _NSError(__FUNC__, sprintf(__VA_ARGS__))

/** Logs a warning message, with timestamp.
	 The console variable `g_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define NSWarning(...) _NSWarning(__FUNC__, sprintf(__VA_ARGS__))

/** Generates an assertion, if a given condition is false.
	 The console variable `g_developer` has to be `1` for them to be visible.

@param condition is the expression to be evaluated.
@param description(...) contains a formatted string containing an error description. */

#define NSAssert(condition, ...) if (autocvar_g_developer) _NSAssert(condition, __FUNC__, sprintf(__VA_ARGS__))

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
		NSLog("---------------------------------------------------");
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

	NSLog( "%s %s %s", sideLeft, functionName, sideRight);
}

void
_InitStart(string functionName)
{
	if (g_initTime != 0)
		error("Called InitStart() without InitEnd()ing the previous one!");

	InitPrint(functionName);
	g_initTime = gettime(1);
}

#define InitStart() _InitStart(__FUNC__)


void
_InitEnd(void)
{
	float endTime = gettime(1);
	NSLog("loaded in %.1f seconds", (endTime - g_initTime));
	NSLog("---------------------------------------------------");
	g_initTime = 0;
}

#define InitEnd() _InitEnd()
