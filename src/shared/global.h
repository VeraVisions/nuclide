/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifdef DOXYGEN
/** Doxygen doesn't know what enumflags (aka bitfields) are, used as e.g. */
#define enumflags enum
#endif

void
_NSLog(string msg)
{
	if (cvar("g_developer") == 1)
		print(sprintf("%f %s\n", time, msg));
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

void
_NSEntWarning(string className, vector classOrg, string warnMessage)
{
	print(sprintf("^1Class %s at %v: %s\n", className, classOrg, warnMessage));
}

/** Logs an error type message, with timestamp.
	 The console variable `g_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define NSLog(...) _NSLog(sprintf(__VA_ARGS__))

/** Generates an assertion, if a given condition is false.

@param condition is the expression to be evaluated.
@param description(...) contains a formatted string containing an error description. */

#define NSAssert(condition, ...) _NSAssert(condition, __FUNC__, sprintf(__VA_ARGS__))


#define NSEntWarning(...) _NSEntWarning(classname, origin, sprintf(__VA_ARGS__))

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