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
#define enumflags enum
#endif

void
_NSLog(string msg)
{
	if (cvar("g_developer") == 1)
		print(sprintf("%f %s\n", time, msg));
}
#define NSLog(...) _NSLog(sprintf(__VA_ARGS__))

enumflags
{
       SEARCH_INSENSITIVE,
       SEARCH_FULLPACKAGE,
       SEARCH_ALLOWDUPES,
       SEARCH_FORCESEARCH,
       SEARCH_MULTISEARCH,
       SEARCH_NAMESORT
};

const vector g_vec_null = [0.0f, 0.0f, 0.0f];