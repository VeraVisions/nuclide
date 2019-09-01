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

void GameText_Draw(void)
{
	drawfont = FONT_20;
	for (int i = 0; i < 5; i++) {
		float a = 0.0f;
		vector rpos;
		float mtime;
		float btime;
		float strwidth;

		mtime = g_textchannels[i].m_flFadeIn + g_textchannels[i].m_flHoldTime + g_textchannels[i].m_flFadeOut;
		btime = g_textchannels[i].m_flFadeIn + g_textchannels[i].m_flHoldTime;

		if (g_textchannels[i].m_flTime > mtime) {
			continue;
		}
		strwidth = stringwidth(g_textchannels[i].m_strMessage, TRUE, [20,20]);

		if (g_textchannels[i].m_flPosX == -1) {
			rpos[0] = (video_res[0] / 2) - (strwidth/2);
		} else {
			rpos[0] = video_res[0] * g_textchannels[i].m_flPosX;

			if (g_textchannels[i].m_flPosX >= 0.5) {
				rpos[0] -= strwidth;
			}
		}

		if (g_textchannels[i].m_flPosY == -1) {
			rpos[1] = (video_res[1] / 2) - 6;
		} else {
			rpos[1] = ((video_res[1] - 12) * g_textchannels[i].m_flPosY);
		}

		if (g_textchannels[i].m_flTime < g_textchannels[i].m_flFadeIn) {
			a = (g_textchannels[i].m_flTime / g_textchannels[i].m_flFadeIn);
		} else if (g_textchannels[i].m_flTime < btime) {
			a = 1.0f;
		} else if (g_textchannels[i].m_flTime < mtime) {
			if (g_textchannels[i].m_flFadeOut) {
				a = 1 - (g_textchannels[i].m_flTime - btime) / g_textchannels[i].m_flFadeOut;
			}
		}

		if (g_textchannels[i].m_flPosX >= 0.5) {
			drawstring(rpos, g_textchannels[i].m_strMessage, '20 20', g_textchannels[i].m_vecColor2, a, DRAWFLAG_ADDITIVE );
		} else {
			drawstring(rpos, g_textchannels[i].m_strMessage, '20 20', g_textchannels[i].m_vecColor2, a, DRAWFLAG_ADDITIVE );
		}

		g_textchannels[i].m_flTime += clframetime;
	}

	drawfont = FONT_CON;
}

void GameText_Parse(void)
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

void GameMessage_Parse(void)
{
	string strSound;
	float flVolume;
	int iAttenuation;

	/* TODO: Fill in the other string data from titles.txt */
	g_textchannels[0].m_strMessage = readstring();
	g_textchannels[0].m_flTime = 0.0f;

	g_textchannels[0].m_flPosX = -1;
	g_textchannels[0].m_flPosY = 0.75f;
	g_textchannels[0].m_flFadeIn = 0.5f;
	g_textchannels[0].m_flFadeOut = 0.5f;
	g_textchannels[0].m_flHoldTime = 4.0f;
	g_textchannels[0].m_vecColor1 = [1,1,1];
	g_textchannels[0].m_vecColor2 = [1,1,1];

	strSound = readstring();
	flVolume = readfloat();
	iAttenuation = readbyte();

	sound(self, CHAN_ITEM, strSound, flVolume, iAttenuation);
}
