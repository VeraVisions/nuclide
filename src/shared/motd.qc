/*
 * Copyright (c) 2024 Vera Visions LLC.
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

#ifdef CLIENT
static string g_motd_body;
static int g_motd_lines;
#endif

void
MOTD_Init(void)
{
	InitStart();
#ifdef SERVER

	/* wipe the slate clean */
	for (int i = 0; i < MOTD_LINES; i++) {
		localcmd(sprintf("serverinfo motdline%i \"\"\n", i));
	}
	localcmd("serverinfo motdlines \"\"\n");
#endif
#ifdef CLIENT
	int motdLines = stoi(serverkey("motdlines"));
	g_motd_body = "";

	for (int i = 0; i < motdLines; i++) {
		string line = serverkey(sprintf("motdline%i", i));
		if (line != "/") {
			g_motd_body = strcat(g_motd_body, line, "\n");
		} else {
			g_motd_body = strcat(g_motd_body, "\n");
		}
	}

	g_motd_lines = motdLines;
#endif
	InitEnd();
}

#ifdef SERVER
void
MOTD_LoadDefault(void)
{
	MOT_LoadFromFile(MOTD_FILE);
}

void
MOT_LoadFromFile(string fileName)
{
	/* init motd */
	string tempString;
	int motdLines = 0;

	filestream fileMotd = fopen(fileName, FILE_READ);

	/* now read in the new motd */
	if (fileMotd != -1) {
		for (int i = 0; i < MOTD_LINES; i++) {
			tempString = fgets(fileMotd);
			if not (tempString) {
				break;
			} else if (tempString == __NULL__) {
				localcmd(sprintf("serverinfo motdline%i /\n", motdLines));
			} else {
				localcmd(sprintf("serverinfo motdline%i %S\n", motdLines, tempString));
			}

			motdLines++;
		}
		localcmd(sprintf("serverinfo motdlines \"%i\"\n", motdLines));
		fclose(fileMotd);
	} else {
		NSLog("Failed to parse motd from %S", MOTD_FILE);
	}
}
#endif

#ifdef CLIENT
string
MOTD_GetTextBody(void)
{
	if (g_motd_lines > 0i)
		return g_motd_body;
	else
		return "Server advertises no message of the day.";
}

int
MOTD_GetLineCount(void)
{
	return g_motd_lines;
}
#endif
