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
	for (entity e = world;(e = find(e, ::classname, "player"));) {
		if (clienttype(e) == CLIENTTYPE_BOT) {
			if (e.netname == botName) {
				return (true);
			}
		}
	}

	return (false);
}

bool
Bot_AddBot_f(string botName)
{
	int extraCount = 0i;
	int foundID = -1i;
	entity oldSelf;
	NSBot newBot;
	int i = 0i;

	if (!botName) {
		print("Usage: Addbot <botname> [skill 1-5] [team] [msec delay] [altname]\n");
		return (false);
	}

	if (!g_nodes_present) {
		print("^1BotScript_Add^7: Can't add bot. No waypoints.\n");
		return (false);
	}

	/* grab the right profile id */
	for (i = 0i; i < g_botScriptCount; i++) {
		if (g_bots[i].m_strName == botName) {
			foundID = i;
		}
	}

	if (foundID == -1i) {
		print("^1BotScript_Add^7: Named profile not found.\n");
		return (false);
	}

	oldSelf = self;
	self = spawnclient();

	if (!self) {
		print("^1BotScript_Add^7: Can't add bot. Server is full\n");
		self = oldSelf;
		return (false);
	}

	newBot = (NSBot)self;
	newBot.SetInfoKey("name", g_bots[foundID].m_strNetName);

	extraCount = tokenize(g_bots[foundID].m_strExtra);

	for (i = 0i; i < extraCount; i+=2) {
		newBot.SetInfoKey(argv(i), argv(i+1));
	}

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
		print("^1BotProfile_AddRandom^7: Not enough profiles available.\n");
		return (false);
	}

	Bot_AddBot_f(g_bots[spawnBot].m_strName);
	return (true);
}

void
BotProfile_Init(void)
{
	filestream botScript;
	string tempString;
	botScript_t currentDef;
	int braceDepth = 0i;

	g_botScriptCount = 0i;

	if (autocvar(bot_enable, 1) == 0) {
		return;
	}

	botScript = fopen("scripts/bots.txt", FILE_READ);

	if (botScript < 0) {
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
	print(sprintf("%i bots parsed\n", g_botScriptCount));
}

void
Bot_ListBotProfiles_f(void)
{
	if (!g_botScriptCount) {
		print("no bot profiles found.\n");
		return;
	}

	for (int i = 0; i < g_botScriptCount; i++) {
		print(sprintf("%i: %s\n", i, g_bots[i].m_strName));
		print(sprintf("\t%S\n", g_bots[i].m_strNetName));
		print(sprintf("\t%s\n", g_bots[i].m_strExtra));
	}
}