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

/* extremely primitive rich presence stuff that'll be extended later down the line or something */

#define RICHPRESENCE_KEYS 2

typedef enum
{
	RICHPRES_STATUS,
	RICHPRES_CONNECT
} richpresence_t;

string g_richpres[RICHPRESENCE_KEYS];
var bool g_richpresence_set = false;
void FragNet_UpdateStatus(string foo, string bar);

void
RichPresence_Set(string strKey, string strValue)
{
	switch (strKey) {
	/* just fluff */
	case "status":
		g_richpres[RICHPRES_STATUS] = strValue;
		//print(sprintf("^2Client Rich Presence: Status changed to '%s'\n", strValue));
		break;
	/* a command line that'll allow others to join our game */
	case "connect":
		g_richpres[RICHPRES_CONNECT] = strValue;
		//print(sprintf("^2Client Rich Presence: Connection parm changed to '%s'\n", strValue));
		break;
	}

	g_richpresence_set = true;
	FragNet_UpdateStatus(g_richpres[RICHPRES_STATUS], g_richpres[RICHPRES_CONNECT]);
};

void
RichPresence_Clear(void)
{
	for (int i = 0; i < RICHPRESENCE_KEYS; i++)
		g_richpres[i] = "";

	g_richpresence_set = false;
}

void
RichPresence_DumpInfo(void)
{
	for (int i = 0; i < RICHPRESENCE_KEYS; i++)
		print(sprintf("[%i] %s\n", i, g_richpres[i]));
}

bool
RichPresence_WasSet(void)
{
	return g_richpresence_set;
}
