/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any+
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

#ifdef WASTES
#define GS_BULLET_PHYSICS
#endif

.float delay;
.float wait;
.float wait;

void Effect_CreateSpark(vector, vector);
void Effect_BreakModel(int, vector, vector, vector, float);

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

	return mdl;
}
