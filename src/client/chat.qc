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

var bool autocvar_cl_chat_enabled = true;

#define CHAT_LINES 5
#define CHAT_TIME 5

var int g_chatpos[2];
var float g_chattime;
var int g_chatlines = -1;
string g_chatbuffer[CHAT_LINES];
font_s g_fntChat;
string g_chatbuffer_final;

void
Chat_Reload(void)
{
	Font_Load("fonts/chat.font", g_fntChat);
}

/*
 * called every frame pretty much and prints whatever is in the chatbuffer.
 * removes lines after some time, one at a time.
 */
void
Chat_Draw(void)
{
	int i;

	/* the voting stuff resides here too, for now */
	if (serverkey("vote_cmd")) {
		string tempstr;
		vector temppos = [0.0f, 0.0f, 0.0f];
		tempstr = sprintf("^3Vote: %s", serverkey("vote_cmd"));
		temppos[0] = (g_hudres[0]/2) - (stringwidth(tempstr, TRUE, [12,12]) / 2);
		temppos[1] = 96;
		Font_DrawText(temppos, tempstr, g_fntChat);

		tempstr = sprintf(
			"^2Yes (%s): %s    ^1No (%s): %s",
					Util_GetKeyString("vote yes"), serverkey("votes_y"), 
					Util_GetKeyString("vote no"), serverkey("votes_n")
			);
		temppos[0] = (g_hudres[0]/2) - (Font_StringWidth(tempstr, TRUE, g_fntChat) / 2);
		Font_DrawText(temppos + [0,16], tempstr, g_fntChat);
	}

	if (autocvar_cl_chat_enabled == false)
		return;

	g_chatpos[0] = g_hudmins[0] + 16;
	g_chatpos[1] = g_hudmins[1] + (g_hudres[1] / 2) - 80;

	if (g_chatlines < 0) {
		return;
	}

	/* remove messages after a g_chattime has passed */
	if (g_chattime < time) {
		for (i = 0; i < g_chatlines; i++) {
			if (g_chatbuffer[i+1] != __NULL__) {
				g_chatbuffer[i] = g_chatbuffer[i+1];
			} else {
				break;
			}
		}
		g_chatbuffer[g_chatlines] = __NULL__;
		g_chatlines--;
		g_chattime = time + CHAT_TIME;
	}

	Font_DrawField([g_chatpos[0],g_chatpos[1]], [g_hudres[0]/2,g_hudres[1]/2], g_chatbuffer_final, g_fntChat, AF_LEFT | AF_BOTTOM);
}

/*
 * called whenever a new chat message is parsed.
 */
void
Chat_Parse(string msg)
{
	if (g_chatlines < (CHAT_LINES - 1)) {
		g_chatbuffer[g_chatlines + 1] = msg;
		g_chatlines++;
	} else {
		for (int i = 0; i < (CHAT_LINES - 1); i++) {
			g_chatbuffer[i] = g_chatbuffer[i + 1];
		}
		g_chatbuffer[CHAT_LINES - 1] = msg;
	}

	g_chattime = time + CHAT_TIME;

	/* we need to be silent */
	if (autocvar_cl_chat_enabled == false)
		return;

	localsound("misc/talk.wav");

	g_chatbuffer_final = "";

	for (int i = 0; i < CHAT_LINES; i++) {
		if (i == 0)
			g_chatbuffer_final = g_chatbuffer[i];
		else
			g_chatbuffer_final = sprintf("%s\n%s", g_chatbuffer_final, g_chatbuffer[i]);
	}

	/* log to client console */
	print(msg);
	print("\n");
}
