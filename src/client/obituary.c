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

extern vector g_hud_color;

#define OBITUARY_LINES 4
#define OBITUARY_TIME 5

typedef struct {
	string strAttacker;
	string strVictim;

	/* icon */
	string strImage;
	vector vecPos;
	vector vecSize;
	vector vecXY;
	vector vecWH;
} obituary_t;

obituary_t g_obituary[OBITUARY_LINES];
static int g_obituary_count;
float g_obituary_time;

void
Obituary_KillIcon(int id, float w)
{
#ifdef VALVE
	vector spr_size;

	/* fill in the entries and calculate some in advance */
	if (w > 0) {
		spr_size = drawgetimagesize(g_weapons[w].ki_spr);
		g_obituary[id].strImage = g_weapons[w].ki_spr;
		g_obituary[id].vecPos = g_weapons[w].ki_xy;
		g_obituary[id].vecSize = g_weapons[w].ki_size;
		g_obituary[id].vecXY[0] = g_weapons[w].ki_xy[0] / spr_size[0];
		g_obituary[id].vecXY[1] = g_weapons[w].ki_xy[1] / spr_size[1];
		g_obituary[id].vecWH[0] = g_weapons[w].ki_size[0] / spr_size[0];
		g_obituary[id].vecWH[1] = g_weapons[w].ki_size[1] / spr_size[1];
	} else {
		g_obituary[id].strImage = "sprites/640hud1.spr_0.tga";
		g_obituary[id].vecPos = [192,224];
		g_obituary[id].vecSize = [32,16];
		g_obituary[id].vecXY[0] = 192 / 256;
		g_obituary[id].vecXY[1] = 224 / 256;
		g_obituary[id].vecWH[0] = 32 / 256;
		g_obituary[id].vecWH[1] = 16 / 256;
	}
#endif
}

void
Obituary_Add(string attacker, string victim, float weapon, float flags)
{
	int i;
	int x, y;
	x = OBITUARY_LINES;

	/* we're not full yet, so fill up the buffer */
	if (g_obituary_count < x) {
		y = g_obituary_count;
		g_obituary[y].strAttacker = attacker;
		g_obituary[y].strVictim = victim;
		Obituary_KillIcon(y, weapon);
		g_obituary_count++;
	} else {
		for (i = 0; i < (x-1); i++) {
			g_obituary[i].strAttacker = g_obituary[i+1].strAttacker;
			g_obituary[i].strVictim = g_obituary[i+1].strVictim;
			g_obituary[i].strImage = g_obituary[i+1].strImage;
			g_obituary[i].vecPos = g_obituary[i+1].vecPos;
			g_obituary[i].vecSize = g_obituary[i+1].vecSize;
			g_obituary[i].vecXY = g_obituary[i+1].vecXY;
			g_obituary[i].vecWH = g_obituary[i+1].vecWH;
		}
		/* after rearranging, add the newest to the bottom. */
		g_obituary[x-1].strAttacker = attacker;
		g_obituary[x-1].strVictim = victim;
		Obituary_KillIcon(x-1, weapon);
	}

	g_obituary_time = OBITUARY_TIME;
}

void
Obituary_Draw(void)
{
	int i;
	vector vecPos;
	drawfont = FONT_CON;

	vecPos = video_mins + [video_res[0] - 18, 56];

	if (g_obituary_time <= 0 && g_obituary_count > 0) {
		for (i = 0; i < (OBITUARY_LINES-1); i++) {
			g_obituary[i].strAttacker = g_obituary[i+1].strAttacker;
			g_obituary[i].strVictim = g_obituary[i+1].strVictim;
			g_obituary[i].strImage = g_obituary[i+1].strImage;
			g_obituary[i].vecPos = g_obituary[i+1].vecPos;
			g_obituary[i].vecSize = g_obituary[i+1].vecSize;
			g_obituary[i].vecXY = g_obituary[i+1].vecXY;
			g_obituary[i].vecWH = g_obituary[i+1].vecWH;
		}
		g_obituary[OBITUARY_LINES-1].strAttacker = "";

		g_obituary_time = OBITUARY_TIME;
		g_obituary_count--;
	}

	g_obituary_time -= clframetime;

	if (g_obituary_time <= 0) {
		return;
	}

	vector vecItem = vecPos;
	for (i = 0; i < OBITUARY_LINES; i++) {
		string a, v;

		if (!g_obituary[i].strAttacker) {
			return;
		}

		vecItem[0] = vecPos[0];
		
		
		v = g_obituary[i].strVictim;
		drawstring_r(vecItem + [0,2], v, [12,12], [1,1,1], 1.0f, 0);
		vecItem[0] -= stringwidth(v, TRUE, [12,12]) + 4;
		vecItem[0] -= g_obituary[i].vecSize[0];

		drawsubpic(
			vecItem,
			g_obituary[i].vecSize,
			g_obituary[i].strImage,
			g_obituary[i].vecXY,
			g_obituary[i].vecWH,
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		a = g_obituary[i].strAttacker;
		drawstring_r(vecItem + [-4,2], a, [12,12], [1,1,1], 1.0f, 0);
		
		vecItem[1] += 18;
	}
}

void
Obituary_Parse(void)
{
	string attacker;
	string victim;
	float weapon;
	float flags;

	attacker = readstring();
	victim = readstring();
	weapon = readbyte();
	flags = readbyte();

	Obituary_Add(attacker, victim, weapon, flags);
}
