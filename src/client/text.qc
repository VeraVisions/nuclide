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

/* for effect 2 */
static int
GameText_CharCount(float fadein, float timer, string msg)
{
	float len = (timer / fadein);

	if (!fadein || len > strlen(msg))
		return strlen(msg);
	else
		return len;
}

/* the engine its drawstring doesn't like newlines that much */
static void
GameText_DrawString(vector pos, string msg, vector col, float alpha)
{
	vector rpos = [0.0f, 0.0f, 0.0f];
	int c = tokenizebyseparator(msg, "\n");

	for (int i = 0; i < c; i++) {
		float strwidth = Font_StringWidth(argv(i), TRUE, FONT_20);

		if (pos[0] == -1) {
			rpos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (strwidth/2);
		} else {
			rpos[0] = g_hudmins[0] + g_hudres[0] * pos[0];

			if (pos[0] >= 0.5) {
				rpos[0] -= strwidth;
			}
		}

		if (pos[1] == -1) {
			rpos[1] = g_hudmins[1] + (g_hudres[1] / 2) - 6;
		} else {
			rpos[1] = g_hudmins[1] + ((g_hudres[1] - 12) * pos[1]);
		}
		rpos[1] += Font_GetHeight(FONT_20) * i;
		rpos[1] -= (Font_GetHeight(FONT_20) * c) / 2;

		Font_DrawText_RGBA(rpos, argv(i), col, alpha, FONT_20);
	}
}

static void
GameText_DrawMessage(gametext_t *txt, float timer, int highlight)
{
	float a = 0.0f;
	vector rpos = [0.0f, 0.0f, 0.0f];
	float mtime;
	float btime;
	string finalstr;

	/* typing effect */
	if (txt->m_iEffect == 2) {
		/* scan out */
		finalstr = substring(txt->m_strMessage, 0,
			GameText_CharCount(txt->m_flFadeIn, timer,
				txt->m_strMessage));
	} else {
		finalstr = txt->m_strMessage;
	}

	timer = max(0, timer);

	if (highlight) {
		btime = txt->m_flFadeIn * \
			strlen(txt->m_strMessage);
		mtime = btime + txt->m_flFadeOut;
	} else {
		mtime = txt->m_flFadeIn + \
			txt->m_flHoldTime + \
			txt->m_flFadeOut;
		btime = txt->m_flFadeIn + \
			txt->m_flHoldTime;
	}

	if (txt->m_iEffect == 2) {
		mtime = (strlen(txt->m_strMessage) * txt->m_flFadeIn) + txt->m_flHoldTime;
		btime = mtime + txt->m_flFadeOut;
	}

	if (timer > mtime) {
		return;
	}

	if (timer < txt->m_flFadeIn) {
		a = (timer / txt->m_flFadeIn);
	} else if (timer < btime) {
		a = 1.0f;
	} else if (timer < mtime) {
		if (txt->m_flFadeOut) {
			a = 1 - (timer - btime) / txt->m_flFadeOut;
		}
	}

	rpos[0] = txt->m_flPosX;
	rpos[1] = txt->m_flPosY;

	if (highlight) {
		GameText_DrawString(rpos, finalstr, txt->m_vecColor2, a);
	} else {
		GameText_DrawString(rpos, finalstr, txt->m_vecColor1, a);
	}
}

static void
GameText_Copy(gametext_t *src, gametext_t *dest)
{
	dest->m_strMessage = src->m_strMessage;
	dest->m_flTime = src->m_flTime;
	dest->m_flPosX = src->m_flPosX;
	dest->m_iEffect = src->m_iEffect;
	dest->m_vecColor2 = src->m_vecColor2;
	dest->m_flFadeIn = src->m_flFadeIn;
	dest->m_flFadeOut = src->m_flFadeOut;
	dest->m_flHoldTime = src->m_flHoldTime;
	dest->m_flFXTime = src->m_flFXTime;
	dest->m_vecColor1 = src->m_vecColor1;
	dest->m_vecColor2 = src->m_vecColor2;
}

static void
GameText_QueueNext(void)
{
	for (int i = 0; i < (g_textqueue_count-1); i++) {
		GameText_Copy(&g_textqueue[i+1], &g_textqueue[i]);
	}
	g_textqueue_next--;
	g_textqueue_count--;
}

void
GameText_Draw(void)
{
	vector debugPos = [16,16];
	
	if (cvar("r_showTexts") > 0)
		Font_DrawText(debugPos, "Text Debug Information", FONT_CON);

	debugPos[1] += 20;

	for (int i = 0i; i < 6; i++) {
		/* we'll draw the highlight separately */
		GameText_DrawMessage(&g_textchannels[i], g_textchannels[i].m_flTime - g_textchannels[i].m_flFXTime, 0); /* first pass */

		/* effect 0 has no highlight */
		if (g_textchannels[i].m_iEffect != 0)
			GameText_DrawMessage(&g_textchannels[i], g_textchannels[i].m_flTime, 1); /* second pass */

		g_textchannels[i].m_flTime += clframetime;

		if (cvar("r_showTexts") <= 0)
			continue;
		
		Font_DrawText(debugPos, sprintf("Chan %i: E %i T: %f/%f", i, g_textchannels[i].m_iEffect, g_textchannels[i].m_flTime, g_textchannels[i].m_flHoldTime), FONT_CON);
		debugPos[1] += 20;
	}

	/* process the channel 0 queue */
	if (g_textqueue_count <= 0) {
		return;
	}

	/* if the message is empty, move the msgs down by 1 */
	if (g_textqueue[0].m_strMessage == __NULL__) {
		GameText_QueueNext();
	}

	GameText_DrawMessage(&g_textqueue[0], g_textqueue[0].m_flTime - g_textqueue[0].m_flFXTime, 0); /* first pass */

	if (g_textqueue[0].m_iEffect != 0)
		GameText_DrawMessage(&g_textqueue[0], g_textqueue[0].m_flTime, 1); /* second pass */

	g_textqueue[0].m_flTime += clframetime;

	float maxTime;

	if (g_textqueue[0].m_iEffect == 2) {
		float charCount = strlen(g_textqueue[0].m_strMessage);
		maxTime = (charCount * g_textqueue[0].m_flFadeIn) + g_textqueue[0].m_flFadeOut + g_textqueue[0].m_flHoldTime + g_textqueue[0].m_flFXTime;
	} else {
		maxTime = g_textqueue[0].m_flFadeIn + g_textqueue[0].m_flFadeOut + g_textqueue[0].m_flHoldTime + g_textqueue[0].m_flFXTime;
	}

	if (g_textqueue[0].m_flTime >= maxTime)
		g_textqueue[0].m_strMessage = __NULL__;

}

void
GameText_ParseString(void)
{
	int chan = readbyte();

	/* last channel is reserved for text menus */
	if (!(chan >= 0 && chan <= 4)) {
		return;
	}

	g_textchannels[chan].m_strMessage = Titles_ParseFunString(readstring());
	g_textchannels[chan].m_flPosX = readfloat();
	g_textchannels[chan].m_flPosY = readfloat();
	g_textchannels[chan].m_iEffect = readbyte();
	g_textchannels[chan].m_vecColor1[0] = readbyte() / 255;
	g_textchannels[chan].m_vecColor1[1] = readbyte() / 255;
	g_textchannels[chan].m_vecColor1[2] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[0] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[1] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[2] = readbyte() / 255;
	g_textchannels[chan].m_flFadeIn = readfloat();
	g_textchannels[chan].m_flFadeOut = readfloat();
	g_textchannels[chan].m_flHoldTime = readfloat();
	g_textchannels[chan].m_flFXTime = readfloat();
	g_textchannels[chan].m_flTime = 0.0f;
}

void
GameText_Parse(void)
{
	int chan = readbyte();

	/* last channel is reserved for text menus */
	if (!(chan >= 0 && chan <= 4)) {
		return;
	}

	g_textchannels[chan].m_strMessage = Titles_ParseFunString(readstring());
	g_textchannels[chan].m_flPosX = readfloat();
	g_textchannels[chan].m_flPosY = readfloat();
	g_textchannels[chan].m_iEffect = readbyte();
	g_textchannels[chan].m_vecColor1[0] = readbyte() / 255;
	g_textchannels[chan].m_vecColor1[1] = readbyte() / 255;
	g_textchannels[chan].m_vecColor1[2] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[0] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[1] = readbyte() / 255;
	g_textchannels[chan].m_vecColor2[2] = readbyte() / 255;
	g_textchannels[chan].m_flFadeIn = readfloat();
	g_textchannels[chan].m_flFadeOut = readfloat();
	g_textchannels[chan].m_flHoldTime = readfloat();
	g_textchannels[chan].m_flFXTime = readfloat();
	g_textchannels[chan].m_flTime = 0.0f;
}

void
GameMessage_Setup(string message, int channel)
{
	gametext_t *next;
	int findid = -1;

	for (int i = 0; i < g_titles_count; i++) {
		if (g_titles[i].m_strName == message) {
			findid = i;
		}
	}

	/* channel 0 is a rotating queue */
	if (channel == 0) {
		/* clear the oldest message if needed */
		if (g_textqueue_next + 1 >= TEXTQUEUE_MAX)
			GameText_QueueNext();

		channel = g_textqueue_next++;
		next = &g_textqueue[channel];
		g_textqueue_count++;

	} else {
		next = &g_textchannels[channel];
	}

	if (findid < 0) {
		next->m_strMessage = Titles_ParseFunString(message);
		next->m_flTime = 0.0f;
		next->m_flPosX = -1;
		next->m_flPosY = 0.75f;
		next->m_flFadeIn = 0.5f;
		next->m_flFadeOut = 0.5f;
		next->m_flHoldTime = 2.0f;
		next->m_vecColor1 = [1,1,1];
		next->m_vecColor2 = [1,1,1];
	} else {
		next->m_strMessage = g_titles[findid].m_strMessage;
		next->m_flTime = 0.0f;
		next->m_flPosX = g_titles[findid].m_flPosX;
		next->m_flPosY = g_titles[findid].m_flPosY;
		next->m_flFadeIn = g_titles[findid].m_flFadeIn;
		next->m_flFadeOut = g_titles[findid].m_flFadeOut;
		next->m_flHoldTime = g_titles[findid].m_flHoldTime;
		next->m_vecColor1 = g_titles[findid].m_vecColor1;
		next->m_vecColor2 = g_titles[findid].m_vecColor2;
		next->m_iEffect = g_titles[findid].m_iEffect;
	}
}

void
GameMessage_Parse(void)
{
	string strSound;
	float flVolume;
	int iAttenuation;
	string findme;

	findme = strtoupper(readstring());
	GameMessage_Setup(findme, 0);

	strSound = readstring();
	flVolume = readfloat();
	iAttenuation = readbyte();

	if (strSound)
		sound(self, CHAN_ITEM, strSound, flVolume, iAttenuation);
}
