/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

float g_printtime;
string g_printbuffer[5];
var int g_printlines = -1;

void CSQC_DrawText(vector pos, string txt, vector sz, vector col, float a, 
					float fl, float fnt)
{
	drawfont = fnt;
	drawstring(pos, txt, sz, col, a, fl);
}

/*
=================
Chat_Draw

Just prints whatever is in the chat buffer and removes lines after some time.
=================
*/
void Print_Draw(void) {
	vector pos = video_mins + [16, 16];
	
	if (g_printlines < 0) {
		return;
	}

	// Remove messages after a g_chattime has passed
	if (g_printtime < time) {
		g_printbuffer[g_printlines] = __NULL__;
		g_printlines--;
		g_printtime = time + 5;
	}
	

	for (int i = 0; i < 5; i++) {
		drawstring(pos, g_printbuffer[i], [12,12], [1,1,1], 1.0f, 0);
		pos_y += 14;
	}
}

/*
=================
CSQC_DrawCenterprint

Read centerprints from a buffer and display them with alpha and whatnot
=================
*/
float fCenterPrintAlpha;
float fCenterPrintTime;
float fCenterPrintLines;
string sCenterPrintBuffer[18];

void CSQC_DrawCenterprint(void)
{	
	if (fCenterPrintAlpha <= 0) {
		return;
	}
	
	vector vCenterPrintPos;
	
	if (fCenterPrintTime > time) {
		fCenterPrintAlpha = 1;
	} else {
		fCenterPrintAlpha -= frametime;
		
		if (fCenterPrintAlpha < 0) {
			fCenterPrintAlpha = 0;
		}
	}
	
	vCenterPrintPos_y = video_mins_y + (video_res_y / 2) - (fCenterPrintLines - 4) - 69;
	
	for (int i = 0; i < (fCenterPrintLines); i++) {
		vCenterPrintPos_x = video_mins_x + (video_res_x / 2) - (stringwidth(sCenterPrintBuffer[i], TRUE, '12 12') / 2);
		drawstring(vCenterPrintPos, sCenterPrintBuffer[i], '12 12', '1 1 1', fCenterPrintAlpha, 0);
		vCenterPrintPos_y += 8;
	}
}
