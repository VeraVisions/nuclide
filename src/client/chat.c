/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

#define CHAT_LINES 5
#define CHAT_TIME 5

var int g_chatpos[2];
var float g_chattime;
var int g_chatlines = -1;
string g_chatbuffer[CHAT_LINES];

/*
 * called every frame pretty much and prints whatever is in the chatbuffer.
 * removes lines after some time, one at a time.
 */
void
Chat_Draw(void)
{
	int i;
	g_chatpos[0] = video_mins[0] + 16;
	g_chatpos[1] = video_mins[1] + video_res[1] - 128;

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

	for (i = 0; i < CHAT_LINES; i++) {
		drawstring([g_chatpos[0],g_chatpos[1]], g_chatbuffer[i], 
			[12,12], [1,1,1], 1.0f, 0);
		g_chatpos[1] += 14;
	}
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
	localsound("misc/talk.wav");

	/* log to client console */
	print(msg);
	print("\n");
}
