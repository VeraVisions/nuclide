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

void
Cross_Draw(string strMat, vector vecSize)
{
	Cross_DrawSubRGBA(strMat, vecSize, [0,0], [1,1], [1.0f, 1.0f, 1.0f], 1.0f);
}

void
Cross_DrawRGB(string strMat, vector vecSize, vector vecColor)
{
	Cross_DrawSubRGBA(strMat, vecSize, [0,0], [1,1], vecColor, 1.0f);
}

void
Cross_DrawRGBA(string strMat, vector vecSize, vector vecColor, float flAlpha)
{
	Cross_DrawSubRGBA(strMat, vecSize, [0,0], [1,1], vecColor, flAlpha);
}

void
Cross_DrawSub(string strMat, vector vecSize, vector vecSrcPos, vector vecSrcSize)
{
	Cross_DrawSubRGBA(strMat, vecSize, vecSrcPos, vecSrcSize, [1.0f, 1.0f, 1.0f], 1.0f);
}

void
Cross_DrawSubRGB(string strMat, vector vecSize, vector vecSrcPos, vector vecSrcSize, vector vecColor)
{
	Cross_DrawSubRGBA(strMat, vecSize, vecSrcPos, vecSrcSize, vecColor, 1.0f);
}

void
Cross_DrawSubRGBA(string strMat, vector vecSize, vector vecSrcPos, vector vecSrcSize, vector vecColor, float flAlpha)
{
	static vector cross_pos;

	if (cvar("pm_thirdPerson") < 1) {
		cross_pos = g_hudmins + (g_hudres / 2) + [-(vecSize[0]/2),-(vecSize[1]/2)];
		cross_pos[0] = rint(cross_pos[0]);
		cross_pos[1] = rint(cross_pos[1]);

		/* terrible hack to deal with engine's bad autoscale positioning */
		if (cvar("vid_conautoscale") > 1) {
			cross_pos[0] -= 0.25f;
			cross_pos[1] -= 0.25f;
		}
		
		drawsubpic(cross_pos, vecSize, strMat, vecSrcPos, vecSrcSize, vecColor, flAlpha, DRAWFLAG_NORMAL);
	} else {
		vector vecSrc;
		vector vecDst;
		player pl = (player)pSeat->m_ePlayer;

		vecSrc = pSeat->m_vecPredictedOrigin + pSeat->m_ePlayer.view_ofs;
		makevectors(view_angles);
		vecDst = (vecSrc + v_forward * 4096);
		traceline(vecSrc, vecDst, MOVE_NORMAL, pSeat->m_ePlayer);
		cross_pos = project(trace_endpos) + [-(vecSize[0]/2),-(vecSize[1]/2)];
		cross_pos[0] = rint(cross_pos[0]);
		cross_pos[1] = rint(cross_pos[1]);
		drawsubpic(cross_pos, vecSize, strMat, vecSrcPos, vecSrcSize, vecColor, flAlpha, DRAWFLAG_NORMAL);
	}
}