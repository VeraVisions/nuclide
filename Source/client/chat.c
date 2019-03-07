/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define CHAT_LINES 5
#define CHAT_TIME 	5

var float g_chattime;
var int g_chatlines = -1;
string g_chatbuffer[CHAT_LINES];

/*
=================
Chat_Draw

Just prints whatever is in the chat buffer and removes lines after some time.
=================
*/
void Chat_Draw(void)
{
	vector pos = video_mins + [16, video_res_y - 128];

	if (g_chatlines < 0) {
		return;
	}

	// Remove messages after a g_chattime has passed
	if (g_chattime < time) {
		for (int i = 0; i < g_chatlines; i++) {
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

	for (int i = 0; i < CHAT_LINES; i++) {
		drawstring(pos, g_chatbuffer[i], [12,12], [1,1,1], 1.0f, 0);
		pos_y += 14;
	}
}

void Chat_Parse(string msg)
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
	sound(pSeat->ePlayer, CHAN_ITEM, "misc/talk.wav", 1.0, ATTN_NONE);
}
