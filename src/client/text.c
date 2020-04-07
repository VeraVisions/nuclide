/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

typedef struct
{
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
	float m_flTime;
} gametext_t;
gametext_t g_textchannels[5];

/* for effect 2 */
int GameText_CharCount(float fadein, float timer, string msg)
{
	float len = (timer / fadein);

	if (!fadein || len > strlen(msg))
		return strlen(msg);
	else 
		return len;
}

/* the engine its drawstring doesn't like newlines that much */
void
GameText_DrawString(vector pos, string msg, vector col, float alpha)
{
	vector rpos;
	int c = tokenizebyseparator(msg, "\n");
	
	for (int i = 0; i < c; i++) {
		float strwidth = stringwidth(argv(i), TRUE, [20,20]);

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
		rpos[1] += 20 * i;
		rpos[1] -= (20 * c) / 2;
		drawstring(rpos, argv(i), '20 20', col, alpha,
			DRAWFLAG_ADDITIVE);
	}
}

void
GameText_DrawMessage(int i, float timer, int highlight)
{
	float a = 0.0f;
	vector rpos;
	float mtime;
	float btime;
	string finalstring;

	if (g_textchannels[i].m_iEffect == 2) {
		/* scan out */
		finalstring = substring(g_textchannels[i].m_strMessage, 0,
			GameText_CharCount(g_textchannels[i].m_flFadeIn, timer,
				g_textchannels[i].m_strMessage));
	} else {
		finalstring = g_textchannels[i].m_strMessage;
	}

	timer = max(0, timer);

	if (highlight) {
		btime = g_textchannels[i].m_flFadeIn * strlen(g_textchannels[i].m_strMessage);
		mtime = btime + g_textchannels[i].m_flFadeOut;
	} else {
		mtime = g_textchannels[i].m_flFadeIn + g_textchannels[i].m_flHoldTime + g_textchannels[i].m_flFadeOut;
		btime = g_textchannels[i].m_flFadeIn + g_textchannels[i].m_flHoldTime;
	}

	if (timer > mtime) {
		return;
	}

	if (timer < g_textchannels[i].m_flFadeIn) {
		a = (timer / g_textchannels[i].m_flFadeIn);
	} else if (timer < btime) {
		a = 1.0f;
	} else if (timer < mtime) {
		if (g_textchannels[i].m_flFadeOut) {
			a = 1 - (timer - btime) / g_textchannels[i].m_flFadeOut;
		}
	}

	rpos[0] = g_textchannels[i].m_flPosX;
	rpos[1] = g_textchannels[i].m_flPosY;
	if (highlight) {
		GameText_DrawString(rpos, finalstring, g_textchannels[i].m_vecColor2, a);
	} else {
		GameText_DrawString(rpos, finalstring, g_textchannels[i].m_vecColor1, a);
	}
}

void
GameText_Draw(void)
{
	drawfont = FONT_20;
	for (int i = 0; i < 5; i++) {
		GameText_DrawMessage(i, g_textchannels[i].m_flTime - g_textchannels[i].m_flFXTime, 0);
		GameText_DrawMessage(i, g_textchannels[i].m_flTime, 1);
		g_textchannels[i].m_flTime += clframetime;
	}

	drawfont = FONT_CON;
}

void
GameText_Parse(void)
{
	int chan = readbyte();
	g_textchannels[chan].m_strMessage = readstring();
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
GameMessage_Setup(string message)
{
	int findid = -1;

	for (int i = 0; i < g_titles_count; i++) {
		if (g_titles[i].m_strName == message) {
			findid = i;
		}
	}

	if (findid < 0) {
		g_textchannels[0].m_strMessage = message;
		g_textchannels[0].m_flTime = 0.0f;
		g_textchannels[0].m_flPosX = -1;
		g_textchannels[0].m_flPosY = 0.75f;
		g_textchannels[0].m_flFadeIn = 0.5f;
		g_textchannels[0].m_flFadeOut = 0.5f;
		g_textchannels[0].m_flHoldTime = 4.0f;
		g_textchannels[0].m_vecColor1 = [1,1,1];
		g_textchannels[0].m_vecColor2 = [1,1,1];
	} else {
		g_textchannels[0].m_strMessage = g_titles[findid].m_strMessage;
		g_textchannels[0].m_flTime = 0.0f;
		g_textchannels[0].m_flPosX = g_titles[findid].m_flPosX;
		g_textchannels[0].m_flPosY = g_titles[findid].m_flPosY;
		g_textchannels[0].m_flFadeIn = g_titles[findid].m_flFadeIn;
		g_textchannels[0].m_flFadeOut = g_titles[findid].m_flFadeOut;
		g_textchannels[0].m_flHoldTime = g_titles[findid].m_flHoldTime;
		g_textchannels[0].m_vecColor1 = g_titles[findid].m_vecColor1;
		g_textchannels[0].m_vecColor2 = g_titles[findid].m_vecColor2;
		g_textchannels[0].m_iEffect = g_titles[findid].m_iEffect;
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
	GameMessage_Setup(findme);

	strSound = readstring();
	flVolume = readfloat();
	iAttenuation = readbyte();

	sound(self, CHAN_ITEM, strSound, flVolume, iAttenuation);
}
