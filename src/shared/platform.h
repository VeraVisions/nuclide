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

typedef enum
{
	PLATFORM_UNINITIALIZED = -1,
	PLATFORM_UNKNOWN = 0,
	PLATFORM_PC,
	PLATFORM_CONSOLE,
	PLATFORM_TOUCH,
	PLATFORM_WEB
} platform;

var platform g_platform = PLATFORM_UNINITIALIZED;

/* fast way to query which system we're on */
platform
Platform_GetPlatform(void)
{
	if (g_platform == PLATFORM_UNINITIALIZED) {
		string osname = cvar_string("sys_platform");
		g_platform = PLATFORM_UNKNOWN;

		switch (osname) {
		case "Web":
			g_platform = PLATFORM_WEB;
			break;
		case "WinCE":
		case "Xbox":
			g_platform = PLATFORM_CONSOLE;
			break;
		case "WinRT":
		case "iOSSim":
		case "iOS":
		case "Android":
			g_platform = PLATFORM_TOUCH;
			break;
		case "Unknown":
		case "Nacl":
		case "Win":
		case "Win16":
		case "Cygwin":
		case "Linux":
		case "Mac":
		case "Apple":
		case "FreeBSD":
		case "OpenBSD":
		case "NetBSD":
		case "BSD":
		case "MorphOS":
		case "AmigaOS":
		case "MacOS X":
		case "Dos":
		default:
			g_platform = PLATFORM_PC;
			break;
		}
	}

	return g_platform;
}

bool
Platform_FileInGamedir(string fileName, string gameDir)
{
	searchhandle fileSearch;
	int fileCount = 0i;

	fileSearch = search_begin(fileName, SEARCH_FULLPACKAGE, TRUE);
	fileCount = search_getsize(fileSearch);

	NSLog("Looking for %S in %S", fileName, gameDir);

	/* doesn't exist */
	if (fileCount <= 0)
		return false;

	for (int i = 0; i < fileCount; i++) {
		string fileDir;
		string fullPath = search_getpackagename(fileSearch, i);
		fileDir = substring(fullPath, 0, strlen(gameDir)); /* only need to check same-ness */

		if (fileDir == gameDir) {
			NSLog("Found %S in %S", fileName, gameDir);
			return true;
		}
	}

	NSError("Did not find %S in %S", fileName, gameDir);

	/* file exists but is in a different gamedir */
	return false;
}

bool
Platform_FileInCurrentGamedir(string fileName)
{
	string gameDir = cvar_string("game");
	return Platform_FileInGamedir(fileName, gameDir);
}
