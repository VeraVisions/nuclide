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

void
Print_Draw(void)
{
	vector pos = g_hudmins + [16, 16];

	if (pSeat->m_iPrintLines < 0) {
		return;
	}

	if (pSeat->m_flPrintTime < time) {
		pSeat->m_strPrintBuffer[pSeat->m_iPrintLines] = __NULL__;
		pSeat->m_iPrintLines--;
		pSeat->m_flPrintTime = time + 5;
	}

	for (int i = 0; i < 5; i++) {
		drawstring(pos, pSeat->m_strPrintBuffer[i], [12,12], [1,1,1], 1.0f, 0);
		pos[1] += 14;
	}
}

void
Print_DrawCenterprint(void)
{
	vector vecPos;

	if (pSeat->m_flCenterprintAlpha <= 0) {
		return;
	}

	if (pSeat->m_flCenterprintTime > time) {
		pSeat->m_flCenterprintAlpha = 1;
	} else {
		pSeat->m_flCenterprintAlpha -= clframetime;
		
		if (pSeat->m_flCenterprintAlpha < 0) {
			pSeat->m_flCenterprintAlpha = 0;
		}
	}

	vecPos[1] = g_hudmins[1] + (g_hudres[1] / 2) - (pSeat->m_iCenterprintLines - 4) - 69;

	for (int i = 0; i < (pSeat->m_iCenterprintLines); i++) {
		vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(pSeat->m_strCenterprintBuffer[i], TRUE, '12 12') / 2);
		Font_DrawText_A(vecPos, pSeat->m_strCenterprintBuffer[i], pSeat->m_flCenterprintAlpha, FONT_CON);
		vecPos[1] += 8;
	}
}
