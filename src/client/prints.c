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

float g_printtime;
string g_printbuffer[5];
var int g_printlines = -1;

void
Print_Draw(void)
{
	vector pos = video_mins + [16, 16];

	if (g_printlines < 0) {
		return;
	}

	if (g_printtime < time) {
		g_printbuffer[g_printlines] = __NULL__;
		g_printlines--;
		g_printtime = time + 5;
	}
	

	for (int i = 0; i < 5; i++) {
		drawstring(pos, g_printbuffer[i], [12,12], [1,1,1], 1.0f, 0);
		pos[1] += 14;
	}
}

float fCenterPrintAlpha;
float fCenterPrintTime;
float fCenterPrintLines;
string sCenterPrintBuffer[18];

void
CSQC_DrawCenterprint(void)
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
	
	vCenterPrintPos[1] = video_mins[1] + (video_res[1] / 2) - (fCenterPrintLines - 4) - 69;
	
	for (int i = 0; i < (fCenterPrintLines); i++) {
		vCenterPrintPos[0] = video_mins[0] + (video_res[0] / 2) - (stringwidth(sCenterPrintBuffer[i], TRUE, '12 12') / 2);
		drawstring(vCenterPrintPos, sCenterPrintBuffer[i], '12 12', '1 1 1', fCenterPrintAlpha, 0);
		vCenterPrintPos[1] += 8;
	}
}
