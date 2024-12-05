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

vector
Cross_GetPos(vector sizeXY)
{
	vector crossPos;

	if (cvar("pm_thirdPerson") < 1) {
		crossPos = g_hudmins + (g_hudres / 2) + [-(sizeXY[0]/2),-(sizeXY[1]/2)];
		crossPos[0] = rint(crossPos[0]);
		crossPos[1] = rint(crossPos[1]);

		/* terrible hack to deal with engine's bad autoscale positioning */
		if (cvar("vid_conautoscale") > 1) {
			crossPos[0] -= 0.25f;
			crossPos[1] -= 0.25f;
		}
	} else {
		vector vecSrc;
		vector vecDst;
		ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;

		vecSrc = pSeat->m_vecPredictedOrigin + pSeat->m_ePlayer.view_ofs;
		makevectors(view_angles);
		vecDst = (vecSrc + v_forward * 4096);
		traceline(vecSrc, vecDst, MOVE_NORMAL, pSeat->m_ePlayer);
		crossPos = project(trace_endpos) + [-(sizeXY[0]/2),-(sizeXY[1]/2)];
		crossPos[0] = rint(crossPos[0]);
		crossPos[1] = rint(crossPos[1]);
	}

	return (crossPos);
}

void
Cross_Draw(string materialPath, vector sizeXY)
{
	Cross_DrawSubRGBA(materialPath, sizeXY, [0,0], [1,1], [1.0f, 1.0f, 1.0f], 1.0f);
}

void
Cross_DrawRGB(string materialPath, vector sizeXY, vector colorRGB)
{
	Cross_DrawSubRGBA(materialPath, sizeXY, [0,0], [1,1], colorRGB, 1.0f);
}

void
Cross_DrawRGBA(string materialPath, vector sizeXY, vector colorRGB, float alphaValue)
{
	Cross_DrawSubRGBA(materialPath, sizeXY, [0,0], [1,1], colorRGB, alphaValue);
}

void
Cross_DrawSub(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY)
{
	Cross_DrawSubRGBA(materialPath, sizeXY, sourcePosXY, sourceSizeXY, [1.0f, 1.0f, 1.0f], 1.0f);
}

void
Cross_DrawSubRGB(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY, vector colorRGB)
{
	Cross_DrawSubRGBA(materialPath, sizeXY, sourcePosXY, sourceSizeXY, colorRGB, 1.0f);
}

void
Cross_DrawSubRGBA(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY, vector colorRGB, float alphaValue)
{
	vector crossPos = Cross_GetPos(sizeXY);

	if (cvar("pm_thirdPerson") < 1) {
		drawsubpic(crossPos, sizeXY, materialPath, sourcePosXY, sourceSizeXY, colorRGB, alphaValue, DRAWFLAG_NORMAL);
	} else {
		drawsubpic(crossPos, sizeXY, materialPath, sourcePosXY, sourceSizeXY, colorRGB, alphaValue, DRAWFLAG_NORMAL);
	}
}
