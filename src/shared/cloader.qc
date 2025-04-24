/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

#ifndef MAX_CONSTANTS_ID
#define MAX_CONSTANTS_ID 1024
#endif

string g_constIndex[MAX_CONSTANTS_ID];
static int g_constCount;
const string g_constantsFile = "scripts/constants.txt";

void
Constants_Init(void)
{
	filestream constFile;
	string tempString;
	int arguments = 0i;
	int indexCount = 0i;

	InitStart();

	g_constCount = 0i;

	if (!g_hashConstants) {
		g_hashConstants = hash_createtab(2, HASH_ADD);
	}

	constFile = fopen(g_constantsFile, FILE_READ);

	if (constFile < 0) {
		ncWarning("No constants, missing %S", g_constantsFile);
		InitEnd();
		return;
	}

	while ((tempString = fgets(constFile))) {
		arguments = (int)tokenize_console(tempString);

		if (arguments != 2) {
			continue;
		}

		/* sanity bounds check */
		if (!Constants_Add(argv(0), argv(1))) {
			fclose(constFile);
			InitEnd();
			return;
		}
	}

	fclose(constFile);
	InitEnd();
}

bool
Constants_Add(string constantName, string constantValue)
{
	/* sanity bounds check */
	if (g_constCount == MAX_CONSTANTS_ID) {
		ncError("Hit maximum number of %d constants.", MAX_CONSTANTS_ID);
		return (false);
	}

	g_constIndex[g_constCount] = constantValue;
	hash_add(g_hashConstants, constantName, g_constCount);
	g_constCount++;
	return (true);
}

string
Constants_LookUp(string constName, string returnValue)
{
	int constIndex = -1i;

	/* only if we're prefixed */
	if (substring(constName, 0, 1) == "$") {
		constIndex = hash_get(g_hashConstants, substring(constName, 1, -1), -1i);
	}

	return (constIndex == -1i) ? returnValue : g_constIndex[constIndex];
}
