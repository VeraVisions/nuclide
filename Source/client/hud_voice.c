/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
HUD_DrawVoice

Draws a little notification for anyone using voice chat
=================
*/
void Voice_DrawHUD(void) {
	vector pos = video_mins + [video_res[0] - 160, video_res[1] - 136];

	/*for (int i = -1; i > -32; i--) {
		if (getplayerkeyfloat(i, INFOKEY_P_VOIPSPEAKING) == 1) {
			drawfill(pos, [144,24], VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA);
			drawfill(pos, [144, 1], vVGUIColor, VGUI_WINDOW_FGALPHA);
			drawfill([pos[0], pos[1] + 23], [144, 1], vVGUIColor, VGUI_WINDOW_FGALPHA);
			drawfill(pos, [1, 24], vVGUIColor, VGUI_WINDOW_FGALPHA);
			drawfill([pos[0] + 143, pos[1]], [1, 24], vVGUIColor, VGUI_WINDOW_FGALPHA);

			CSQC_DrawText([pos[0] + 28, pos[1] + 8], getplayerkeyvalue(i, "name"), [12,12], vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_NORMAL, FONT_CON);

			drawpic(pos + [2,0], "gfx/vgui/icntlk_sv.tga", [24,24], vVGUIColor, 1, DRAWFLAG_NORMAL);
			pos[1] -= 32;
		}
	}*/
}


/*
=================
Player_PreDraw
=================
*/
void Voice_Draw3D(entity t)
{
	if (getplayerkeyfloat(t.entnum - 1, INFOKEY_P_VOIPSPEAKING)) {
		vector vpos = t.origin + [0,0,48];
		makevectors(view_angles);
		R_BeginPolygon("gfx/vgui/icntlk_pl");
		R_PolygonVertex(vpos + v_right*16 - v_up*16, '1 1', [1,1,1], 1);
		R_PolygonVertex(vpos - v_right*16 - v_up*16, '0 1', [1,1,1], 1);
		R_PolygonVertex(vpos - v_right*16 + v_up*16, '0 0', [1,1,1], 1);
		R_PolygonVertex(vpos + v_right*16 + v_up*16, '1 0', [1,1,1], 1);
		R_EndPolygon();
	}
}
