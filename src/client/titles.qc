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

/*
 * these message titles are used for all sorts of in-game messages.
 * from beginning/end credits to instructions. they're messy as they do not
 * support localizations by design. you effectively just swap titles.txt files
 * out like pokemon cards.
 */

typedef struct titles_s
{
	string m_strName;
	string m_strMessage;
	float m_flPosX;
	float m_flPosY;
	int m_iEffect;
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flFadeIn;
	float m_flFadeOut;
	float m_flHoldTime;
	float m_flFXTime;
} titles_t;
titles_t *g_titles;
int g_titles_count;

titles_t g_title_null =
{
	.m_strName = "",
	.m_strMessage = "",
	.m_flPosX = 0.0f,
	.m_flPosY = -1.0f,
	.m_iEffect = 0,
	.m_vecColor1 = [1,1,1],
	.m_vecColor2 = [1,1,1],
	.m_flFadeIn = 0.5f,
	.m_flFadeOut = 0.5f,
	.m_flHoldTime = 0.0f,
	.m_flFXTime = 2.5f
};

string
Titles_ParseFunString(string temp)
{
	/* empty lines are newlines. */
	if (!temp) {
		return "\n";
	}

	temp = strreplace("\\y", "^3", temp);
	temp = strreplace("\\r", "^1", temp);
	temp = strreplace("\\g", "^2", temp);
	temp = strreplace("\\b", "^4", temp);
	temp = strreplace("\\w", "^7", temp);
	temp = strreplace("\\d", "^8", temp);
	temp = strreplace("\\R", " ", temp);
	temp = strreplace("\\n", "\n", temp);
	temp = strreplace("\\N", "\n", temp);
	return temp;
}

void
Titles_Shutdown(void)
{
	if (g_titles)
		memfree(g_titles);

	g_titles_count = 0;
}

string
Titles_GetTextBody(string shortName)
{
	int foundID = -1i;
	string compare = strtoupper(shortName);

	for (int i = 0; i < g_titles_count; i++) {
		if (g_titles[i].m_strName == compare) {
			foundID = i;
			break;
		}
	}

	if (foundID >= 0)
		return g_titles[foundID].m_strMessage;

	return compare;
}

void
Titles_Init(void)
{
	/* messages in the file inherit the last defined effects etc. */
	float t_position[2];
	int t_effect;
	vector t_color;
	vector t_color2;
	float t_fxtime;
	float t_holdtime;
	float t_fadein;
	float t_fadeout;
	string t_name = "";
	string t_message = "";
	filestream fs_titles;
	filestream fs_titlesGame; /* appended */
	string temp;
	int c;
	int braced;
	int titleID = 0;

	InitStart();

	Titles_Shutdown();

	fs_titles = fopen("titles.txt", FILE_READ);

	if (fs_titles < 0) {
		fs_titles = fopen("scripts/titles.txt", FILE_READ);

		if (fs_titles < 0) {
			ncWarning("No titles, missing [scripts/]titles.txt");
			InitEnd();
			return;
		}
	}

	/* fill in some sane defaults */
	t_position[0] = 0;
	t_position[1] = -1;
	t_effect = 0;
	t_color = [1,1,1];
	t_color2 = [1,1,1];
	t_fxtime = 0.5f;
	t_holdtime = 2.5f;
	t_fadein = 0.5f;
	t_fadeout = 0.5f;
	g_titles_count = 0;

	/* first pass, count entries */
	while ((temp = fgets(fs_titles))) {
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "{":
			braced = TRUE;
			break;
		case "}":
			/* skip broken syntax */
			if (braced == FALSE) {
				break;
			}
			g_titles_count++;
			braced = FALSE;
			break;
		default:
			break;
		}
	}

	fs_titlesGame = fopen(strcat("titles_", cvar_string("fs_game"), ".txt"), FILE_READ);

	/* doesn't matter. optional. */
	if (fs_titlesGame >= 0) {
		while ((temp = fgets(fs_titlesGame))) {
			c = tokenize_console(temp);

			switch(argv(0)) {
			case "{":
				braced = TRUE;
				break;
			case "}":
				/* skip broken syntax */
				if (braced == FALSE) {
					break;
				}
				g_titles_count++;
				braced = FALSE;
				break;
			default:
				break;
			}
		}
	}


	ncLog("read %i titleDefs (%i bytes).", g_titles_count, sizeof(titles_t) * g_titles_count);
	g_titles = memalloc(sizeof(titles_t) * g_titles_count);
	fseek(fs_titles, 0);

	/* insert info into the tree */
	while ((temp = fgets(fs_titles))) {
		/* tons of comments/garbage in those files,
		 * so tokenize appropriately */
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "$position":
			t_position[0] = stof(argv(1));
			t_position[1] = stof(argv(2));
			break;
		case "$effect":
			t_effect = stoi(argv(1));
			break;
		case "$color":
			if (c == 4) {
				t_color[0] = stof(argv(1)) / 255;
				t_color[1] = stof(argv(2)) / 255;
				t_color[2] = stof(argv(3)) / 255;
			} else {
				t_color = stov(argv(1)) / 255;
			}
			break;
		case "$color2":
			if (c == 4) {
				t_color2[0] = stof(argv(1)) / 255;
				t_color2[1] = stof(argv(2)) / 255;
				t_color2[2] = stof(argv(3)) / 255;
			} else {
				t_color2 = stov(argv(1)) / 255;
			}
			break;
		case "$fxtime":
			t_fxtime = stof(argv(1));
			break;
		case "$holdtime":
			t_holdtime = stof(argv(1));
			break;
		case "$fadein":
			t_fadein = stof(argv(1));
			break;
		case "$fadeout":
			t_fadeout = stof(argv(1));
			break;
		case "{":
			braced = TRUE;
			/*print(sprintf("[^1TITLES^7] Found ^2%s\n",
				t_name));
			print(sprintf("%s\n",
					temp));*/
			break;
		case "}":
			/* skip broken syntax */
			if (braced == FALSE) {
				break;
			}
			/*print(sprintf("%s\n",
					temp));*/
			/* time to dump the info */
			g_titles[titleID].m_strName = t_name;
			g_titles[titleID].m_strMessage = t_message;
			g_titles[titleID].m_flPosX = t_position[0];
			g_titles[titleID].m_flPosY = t_position[1];
			g_titles[titleID].m_iEffect = t_effect;
			g_titles[titleID].m_vecColor1 = t_color;
			g_titles[titleID].m_vecColor2 = t_color2;
			g_titles[titleID].m_flFadeIn = t_fadein;
			g_titles[titleID].m_flFadeOut = t_fadeout;
			g_titles[titleID].m_flHoldTime = t_holdtime;
			g_titles[titleID].m_flFXTime = t_fxtime;
			t_message = "";
			t_name = "";
			braced = FALSE;
			titleID++;
			break;
		default:
			if (braced == TRUE) {
				/* append string entry after another */
				temp = Titles_ParseFunString(temp);
				t_message = sprintf("%s%s\n", t_message, temp);
			} else {
				/* name/identifer of our message */
				t_name = strtoupper(temp);
			}
		}
	}
	fclose(fs_titles);

	/* optional */
	if (fs_titlesGame >= 0) {
	fseek(fs_titlesGame, 0);

	/* insert info into the tree */
	while ((temp = fgets(fs_titlesGame))) {
		/* tons of comments/garbage in those files,
		 * so tokenize appropriately */
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "$position":
			t_position[0] = stof(argv(1));
			t_position[1] = stof(argv(2));
			break;
		case "$effect":
			t_effect = stoi(argv(1));
			break;
		case "$color":
			if (c == 4) {
				t_color[0] = stof(argv(1)) / 255;
				t_color[1] = stof(argv(2)) / 255;
				t_color[2] = stof(argv(3)) / 255;
			} else {
				t_color = stov(argv(1)) / 255;
			}
			break;
		case "$color2":
			if (c == 4) {
				t_color2[0] = stof(argv(1)) / 255;
				t_color2[1] = stof(argv(2)) / 255;
				t_color2[2] = stof(argv(3)) / 255;
			} else {
				t_color2 = stov(argv(1)) / 255;
			}
			break;
		case "$fxtime":
			t_fxtime = stof(argv(1));
			break;
		case "$holdtime":
			t_holdtime = stof(argv(1));
			break;
		case "$fadein":
			t_fadein = stof(argv(1));
			break;
		case "$fadeout":
			t_fadeout = stof(argv(1));
			break;
		case "{":
			braced = TRUE;
			/*print(sprintf("[^1TITLES^7] Found ^2%s\n",
				t_name));
			print(sprintf("%s\n",
					temp));*/
			break;
		case "}":
			/* skip broken syntax */
			if (braced == FALSE) {
				break;
			}
			/*print(sprintf("%s\n",
					temp));*/
			/* time to dump the info */
			g_titles[titleID].m_strName = t_name;
			g_titles[titleID].m_strMessage = t_message;
			g_titles[titleID].m_flPosX = t_position[0];
			g_titles[titleID].m_flPosY = t_position[1];
			g_titles[titleID].m_iEffect = t_effect;
			g_titles[titleID].m_vecColor1 = t_color;
			g_titles[titleID].m_vecColor2 = t_color2;
			g_titles[titleID].m_flFadeIn = t_fadein;
			g_titles[titleID].m_flFadeOut = t_fadeout;
			g_titles[titleID].m_flHoldTime = t_holdtime;
			g_titles[titleID].m_flFXTime = t_fxtime;
			t_message = "";
			t_name = "";
			braced = FALSE;
			titleID++;
			break;
		default:
			if (braced == TRUE) {
				/* append string entry after another */
				temp = Titles_ParseFunString(temp);
				t_message = sprintf("%s%s\n", t_message, temp);
			} else {
				/* name/identifer of our message */
				t_name = strtoupper(temp);
			}
		}
	}
	fclose(fs_titlesGame);
	}


	InitEnd();
}


titles_t *g_titles;
int g_titles_count;

void
Titles_AddEntry(titles_t new)
{
	int newcount = g_titles_count + 1;
	g_titles = (titles_t *)memreallocOld(g_titles, sizeof(titles_t), g_titles_count, newcount);
	g_titles[g_titles_count].m_strName = new.m_strName;
	g_titles[g_titles_count].m_strMessage = new.m_strMessage;
	g_titles[g_titles_count].m_flPosX = new.m_flPosX;
	g_titles[g_titles_count].m_flPosY = new.m_flPosY;
	g_titles[g_titles_count].m_iEffect = new.m_iEffect;
	g_titles[g_titles_count].m_vecColor1 = new.m_vecColor1;
	g_titles[g_titles_count].m_vecColor2 = new.m_vecColor2;
	g_titles[g_titles_count].m_flFadeIn = new.m_flFadeIn;
	g_titles[g_titles_count].m_flFadeOut = new.m_flFadeOut;
	g_titles[g_titles_count].m_flHoldTime = new.m_flHoldTime;
	g_titles[g_titles_count].m_flFXTime = new.m_flFXTime;
	g_titles_count++;
}
