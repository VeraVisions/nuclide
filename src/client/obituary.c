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

#define OBITUARY_LINES	4
#define OBITUARY_TIME	5

typedef struct
{
	string attacker;
	string victim;

	/* icon */
	string mtr;
	vector pos;
	vector size;
	vector coord;
	vector bounds;
} obituary_t;

static obituary_t g_obituary[OBITUARY_LINES];
static int g_obituary_count;
static float g_obituary_time;

void
Obituary_KillIcon(int id, float w)
{
#ifdef VALVE
	vector mtrsize;

	/* fill in the entries and calculate some in advance */
	if (w > 0) {
		/*mtrsize = drawgetimagesize(g_weapons[w].ki_spr);
		g_obituary[id].mtr = g_weapons[w].ki_spr;
		g_obituary[id].pos = g_weapons[w].ki_xy;
		g_obituary[id].size = g_weapons[w].ki_size;
		g_obituary[id].coord[0] = g_weapons[w].ki_xy[0] / mtrsize[0];
		g_obituary[id].coord[1] = g_weapons[w].ki_xy[1] / mtrsize[1];
		g_obituary[id].bounds[0] = g_weapons[w].ki_size[0] / mtrsize[0];
		g_obituary[id].bounds[1] = g_weapons[w].ki_size[1] / mtrsize[1];*/
	} else {
		/* generic splat icon */
		g_obituary[id].mtr = "sprites/640hud1.spr_0.tga";
		g_obituary[id].pos = [192,224];
		g_obituary[id].size = [32,16];
		g_obituary[id].coord[0] = 192 / 256;
		g_obituary[id].coord[1] = 224 / 256;
		g_obituary[id].bounds[0] = 32 / 256;
		g_obituary[id].bounds[1] = 16 / 256;
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
		g_obituary[y].attacker = attacker;
		g_obituary[y].victim = victim;
		Obituary_KillIcon(y, weapon);
		g_obituary_count++;
	} else {
		for (i = 0; i < (x-1); i++) {
			g_obituary[i].attacker = g_obituary[i+1].attacker;
			g_obituary[i].victim = g_obituary[i+1].victim;
			g_obituary[i].mtr = g_obituary[i+1].mtr;
			g_obituary[i].pos = g_obituary[i+1].pos;
			g_obituary[i].size = g_obituary[i+1].size;
			g_obituary[i].coord = g_obituary[i+1].coord;
			g_obituary[i].bounds = g_obituary[i+1].bounds;
		}
		/* after rearranging, add the newest to the bottom. */
		g_obituary[x-1].attacker = attacker;
		g_obituary[x-1].victim = victim;
		Obituary_KillIcon(x-1, weapon);
	}

	g_obituary_time = OBITUARY_TIME;
}

void
Obituary_Draw(void)
{
	int i;
	vector pos;
	vector item;
	drawfont = FONT_CON;
	pos = g_hudmins + [g_hudres[0] - 18, 56];

	if (g_obituary_time <= 0 && g_obituary_count > 0) {
		for (i = 0; i < (OBITUARY_LINES-1); i++) {
			g_obituary[i].attacker = g_obituary[i+1].attacker;
			g_obituary[i].victim = g_obituary[i+1].victim;
			g_obituary[i].mtr = g_obituary[i+1].mtr;
			g_obituary[i].pos = g_obituary[i+1].pos;
			g_obituary[i].size = g_obituary[i+1].size;
			g_obituary[i].coord = g_obituary[i+1].coord;
			g_obituary[i].bounds = g_obituary[i+1].bounds;
		}
		g_obituary[OBITUARY_LINES-1].attacker = "";

		g_obituary_time = OBITUARY_TIME;
		g_obituary_count--;
	}

	if (g_obituary_count <= 0) { 
		return;
	}

	item = pos;
	for (i = 0; i < OBITUARY_LINES; i++) {
		string a, v;

		if (!g_obituary[i].attacker) {
			break;
		}

		item[0] = pos[0];
		
		
		v = g_obituary[i].victim;
		drawstring_r(item + [0,2], v, [12,12], [1,1,1], 1.0f, 0);
		item[0] -= stringwidth(v, TRUE, [12,12]) + 4;
		item[0] -= g_obituary[i].size[0];

		drawsubpic(
			item,
			g_obituary[i].size,
			g_obituary[i].mtr,
			g_obituary[i].coord,
			g_obituary[i].bounds,
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		a = g_obituary[i].attacker;
		drawstring_r(item + [-4,2], a, [12,12], [1,1,1], 1.0f, 0);
		item[1] += 18;
	}

	g_obituary_time = max(0, g_obituary_time - clframetime);
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
	
	if (!attacker) {
		return;
	}

	Obituary_Add(attacker, victim, weapon, flags);
	//print("Obituary received\n");
}
