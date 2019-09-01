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

#define SCORE_HEADER_C [255/255,156/255,0]
#define SCORE_LINE_C [255/255,200/255,0]

void Scores_Init(void)
{
	
}

void Scores_Draw(void)
{
	vector pos;
	player pl;
	
	pl = (player)pSeat->ePlayer;
	pos = video_mins + [(video_res[0] / 2) - 145, 30];

	drawfill(pos, [290, 1], SCORE_LINE_C, 1.0f, DRAWFLAG_ADDITIVE);

	drawfont = FONT_20;
	drawstring(pos + [0,-18], "Player", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [124,-18], "kills / deaths", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [240,-18], "latency", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	
	pos[1] += 12;
	for (int i = -1; i > -32; i--) {
		float l;
		string ping;
		string kills;
		string deaths;
		string name;

		name = getplayerkeyvalue(i, "name");

		/* Out of players */
		if (!name) {
			break;
		} else if (name == getplayerkeyvalue(pl.entnum-1, "name")) {
			drawfill(pos, [290, 13], [0,0,1], 0.5f, DRAWFLAG_ADDITIVE);
		}

		drawstring(pos, getplayerkeyvalue(i, "name"), [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		drawstring(pos + [154,0], "/", [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the kills and align them left to right */
		kills = getplayerkeyvalue(i, "frags");
		l = stringwidth(kills, FALSE, [20,20]);
		drawstring(pos + [150 - l,0], kills, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Deaths are right to left aligned */
		deaths = getplayerkeyvalue(i, "*deaths");
		drawstring(pos + [165,0], deaths, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the latency and align it left to right */
		ping = getplayerkeyvalue(i, "ping");
		l = stringwidth(ping, FALSE, [20,20]);

		drawstring(pos + [290 - l,0], ping, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		pos[1] += 20;
	}
	
	drawfont = FONT_CON;
}
