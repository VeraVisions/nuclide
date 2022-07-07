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
=================
Voice_DrawHUD

Draws a little notification for anyone using voice chat
=================
*/
void
Voice_DrawHUD(void)
{
	vector pos = video_mins + [video_res[0] - 160, video_res[1] - 136];

	for (int i = -1; i > -32; i--) {
		if (getplayerkeyfloat(i, INFOKEY_P_VOIPSPEAKING) != 1) {
			continue;
		}

		/* borders */
		drawfill(pos, [144,24], [0,0,0], 0.5f);
		drawfill(pos, [144, 1], UI_MAINCOLOR, 1.0f);
		drawfill([pos[0], pos[1] + 23], [144, 1], UI_MAINCOLOR, 1.0f);
		drawfill(pos, [1, 24], UI_MAINCOLOR, 1.0f);
		drawfill([pos[0] + 143, pos[1]], [1, 24], UI_MAINCOLOR, 1.0f);

		/* icon */
		drawpic(
			pos + [2,0],
			"gfx/vgui/icntlk_sv.tga",
			[24,24],
			UI_MAINCOLOR,
			1.0f,
			DRAWFLAG_NORMAL
		);

		/* speaker name */
		Font_DrawText([pos[0] + 28, pos[1] + 8], getplayerkeyvalue(i, "name"), FONT_CON);
		pos[1] -= 32;
	}
}

/*
=================
Voice_Draw3D

Draws an image above a player in-world if they're speaking over VoIP
=================
*/
void
Voice_Draw3D(entity t)
{
	if (getplayerkeyfloat(t.entnum - 1, INFOKEY_P_VOIPSPEAKING)) {
		vector vpos = t.origin + [0,0,48];
		makevectors(view_angles);
		R_BeginPolygon("gfx/vgui/icntlk_pl");
		R_PolygonVertex(vpos + v_right * 8 - v_up * 8, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(vpos - v_right * 8 - v_up * 8, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(vpos - v_right * 8 + v_up * 8, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(vpos + v_right * 8 + v_up * 8, [1,0], [1,1,1], 1.0f);
		R_EndPolygon();
	}
}
