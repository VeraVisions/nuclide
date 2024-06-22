/*
 * Copyright (c) 2023 Vera Visions LLC.
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

bool
Bot_ExistsInServer(string botName)
{
	string noColor1 = strdecolorize(botName);

	for (entity e = world;(e = find(e, ::classname, "player"));) {
		if (clienttype(e) == CLIENTTYPE_BOT) {
			string noColor2 = strdecolorize(e.netname);

			if (noColor1 == noColor2) {
				return (true);
			}
		}
	}

	return (false);
}

bool
Bot_AddBot_f(string botName, float teamValue, float spawnDelay, string newName)
{
	int extraCount = 0i;
	int foundID = -1i;
	entity oldSelf;
	NSClientPlayer newBot;
	int i = 0i;

	if (!botName) {
		print("Usage: Addbot <botname> [skill 1-5] [team] [msec delay] [altname]\n");
		return (false);
	}

	if (Nodes_Available() == false) {
		NSError("Can't add bot. No nodes.");
		return (false);
	}

	/* grab the right profile id */
	for (i = 0i; i < g_botScriptCount; i++) {
		if (g_bots[i].m_strName == botName) {
			foundID = i;
			break;
		}
	}

	if (foundID == -1i) {
		NSError("Named profile %S not found.", botName);
		return (false);
	}

	oldSelf = self;
	self = spawnclient();

	if (!self) {
		NSError("Unable to add bot. Server is full.");
		self = oldSelf;
		return (false);
	}

	newBot = (NSClientPlayer)self;
	newBot.SetInfoKey("name", g_bots[foundID].m_strNetName);

	extraCount = tokenize(g_bots[foundID].m_strExtra);

	for (i = 0i; i < extraCount; i+=2) {
		newBot.SetInfoKey(argv(i), argv(i+1));
	}

	newBot.SetInfoKey("*bot", "1");
	ClientConnect();
	PutClientInServer();

	self = oldSelf;
	return (true);
}

bool
BotProfile_AddRandom(void)
{
	int startValue = (int)floor(random(0, g_botScriptCount));
	int spawnBot = -1i;

	/* start at a random index */
	for (int i = startValue; i < g_botScriptCount; i++) {
		if (Bot_ExistsInServer(g_bots[i].m_strNetName) == false) {
			spawnBot = i;
			break;
		}
	}

	/* still haven't found it. count down. */
	if (spawnBot == -1i) {
		for (int i = startValue - 1i; i > 0i; i--) {
			if (Bot_ExistsInServer(g_bots[i].m_strNetName) == false) {
				spawnBot = i;
				break;
			}
		}
	}

	/* every bot exists already */
	if (spawnBot == -1i) {
		NSError("Not enough profiles available.");
		return (false);
	}

	Bot_AddBot_f(g_bots[spawnBot].m_strName, 0, 0.0f, __NULL__);
	return (true);
}

void
BotProfile_Init(void)
{
	filestream botScript;
	string tempString;
	botScript_t currentDef;
	int braceDepth = 0i;

	InitStart();

	currentDef.m_strName = "";
	currentDef.m_strNetName = "";
	currentDef.m_strExtra = "";

	g_botScriptCount = 0i;

	if (autocvar(bot_enable, 1) == 0) {
		InitEnd();
		return;
	}

	botScript = fopen("scripts/bots.txt", FILE_READ);

	if (botScript < 0) {
		NSError("Missing file scripts/bots.txt");
		InitEnd();
		return;
	}

	/* line by line */
	while ((tempString = fgets(botScript))) {
		int lineSegments = tokenize_console(tempString);

		/* word for word */
		for (int i = 0i; i < lineSegments; i++) {
			string word = argv(i);

			switch (word) {
			case "{":
				braceDepth++;
				break;
			case "}":
				braceDepth--;

				/* we've reached the end of a definition */
				if (braceDepth == 0) {
					/* we have something somewhat valid I guess */
					if (currentDef.m_strName != "") {
						g_bots[g_botScriptCount].m_strNetName = currentDef.m_strNetName;
						g_bots[g_botScriptCount].m_strExtra = currentDef.m_strExtra;

						if (g_bots[g_botScriptCount].m_strNetName == "") {
							g_bots[g_botScriptCount].m_strNetName = currentDef.m_strName;
						}

						g_bots[g_botScriptCount].m_strName = strtolower(currentDef.m_strName);

						/* increment the def count */
						if (g_botScriptCount < BOTSCRIPT_MAX)
							g_botScriptCount++;
					}
					currentDef.m_strName = "";
					currentDef.m_strNetName = "";
					currentDef.m_strExtra = "";
				}
				break;
			default:
				if (braceDepth == 1) {
					if (word == "name") {
						currentDef.m_strName = argv(i+1);
						i++;
					} else if (word == "funname") {
						currentDef.m_strNetName = argv(i+1);
						i++;
					} else { /* rest gets dumped into extra */
						currentDef.m_strExtra = strcat(currentDef.m_strExtra, "\"", word, "\"", " ");
					}
				}
			}
		}
	}

	fclose(botScript);
	NSLog("...%i bots parsed.", g_botScriptCount);
	InitEnd();
}

void
Bot_ListBotProfiles_f(void)
{
	if (!g_botScriptCount) {
		NSError("No bot profiles available.");
		return;
	}

	for (int i = 0; i < g_botScriptCount; i++) {
		print(sprintf("%i: %s\n", i, g_bots[i].m_strName));
		print(sprintf("\t%S\n", g_bots[i].m_strNetName));
		print(sprintf("\t%s\n", g_bots[i].m_strExtra));
	}
}