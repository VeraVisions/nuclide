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

var string g_strSkyName;
var string g_strSkyPath;

void
Sky_Update(int force)
{
	if (g_strSkyName != serverkey("skyname") || force == TRUE) {
		string skyPath;
		string skyPrefix;

		g_strSkyName = serverkey("skyname");
		skyPrefix = substring(g_strSkyName, 0, 4);

		//print(sprintf("SKY PREFIX: %S\n", skyPrefix));

		/* is it a Source Engine material? */
		if (fileExists(strcat("materials/skybox/", g_strSkyName, "bk.vmt")) == true) {
			skyPath = strcat("materials/skybox/", g_strSkyName);
		} else {
			skyPath = g_strSkyName;
		}

		if not (skyPath)
			return;

		localcmd(sprintf("sky \"%s\"\n", skyPath));
		g_strSkyPath = skyPath;
		NSLog("sky update applying %s.", skyPath);
	}
}

string
Sky_GetMaterial(void)
{
	return (g_strSkyPath);
}
