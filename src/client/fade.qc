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

/*enum
{
	DRAWFLAG_NORMAL,
	DRAWFLAG_ADDITIVE,
	DRAWFLAG_MODULATE, // FTE doesn't support this
	DRAWFLAG_2XMODULATE // FTE doesn't support this
};*/

enumflags
{
	EVF_FADEDROM,
	EVF_MODULATE,
	EVF_ONLYUSER
};

const string mat_fade_modulate =
	"{\n" \
		"{\n" \
			"map $whiteimage\n" \
			"rgbGen vertex\n" \
			"blendFunc GL_DST_COLOR GL_ONE_MINUS_SRC_ALPHA\n" \
			"alphaGen vertex\n" \
		"}\n" \
	"}\n";

/* needs to be called on every vid_reload */
void
Fade_Reload(void)
{
	shaderforname("fade_modulate", mat_fade_modulate);
}

/* run every frame to update the actively running fade effects */
void
Fade_Update (int x, int y, int w, int h)
{
	if (pSeat->m_iFadeActive == FALSE) {
		return;
	}
	if (pSeat->m_flFadeStyle & EVF_FADEDROM) {
		pSeat->m_flFadeAlpha = 1.0f;
		if (pSeat->m_flFadeTime > pSeat->m_flFadeDuration) {
			pSeat->m_flFadeAlpha -= (pSeat->m_flFadeTime - pSeat->m_flFadeDuration) * (1.0 / pSeat->m_flFadeHold);
		}
	} else {
		if (pSeat->m_flFadeTime < pSeat->m_flFadeDuration) {
			pSeat->m_flFadeAlpha = pSeat->m_flFadeTime * (1.0 / pSeat->m_flFadeDuration);
		} else {
			pSeat->m_flFadeAlpha = (pSeat->m_flFadeTime - pSeat->m_flFadeDuration) * (1.0 / pSeat->m_flFadeHold);
		}
	}

	if (pSeat->m_flFadeAlpha > 1.0f) {
		pSeat->m_flFadeAlpha = 1.0f;
	} else if (pSeat->m_flFadeAlpha < 0.0f) {
		pSeat->m_flFadeAlpha = 0.0f;
	}

	/* time's up */
	if (pSeat->m_flFadeTime >= (pSeat->m_flFadeDuration + pSeat->m_flFadeHold)) {
		pSeat->m_iFadeActive = FALSE;
		return;
	}

	if (pSeat->m_flFadeStyle & EVF_MODULATE) {
		drawpic([x, y], "fade_modulate", [w, h], pSeat->m_vecFadeColor, pSeat->m_flFadeAlpha * pSeat->m_flFadeMaxAlpha, 0);
	} else {
		drawfill([x, y], [w, h], pSeat->m_vecFadeColor, pSeat->m_flFadeAlpha * pSeat->m_flFadeMaxAlpha, 0);
	}

	pSeat->m_flFadeTime += clframetime;
}

/* called by a worldspawn key,
   will cause the game to fade-in over the course of 4 seconds */
void
Fade_StartDark(void)
{
	pSeat->m_vecFadeColor = [0.0, 0.0, 0.0];
	pSeat->m_flFadeMaxAlpha = 1.0;
	pSeat->m_flFadeDuration = 5.0;
	pSeat->m_flFadeHold = 4.0f;
	pSeat->m_flFadeStyle = EVF_FADEDROM;
	pSeat->m_flFadeTime = 0.0f;
	pSeat->m_flFadeAlpha = 1.0f;
	pSeat->m_iFadeActive = TRUE;
}

void
Fade_Parse(void)
{
	pSeat->m_vecFadeColor[0] = readfloat();
	pSeat->m_vecFadeColor[1] = readfloat();
	pSeat->m_vecFadeColor[2] = readfloat();
	pSeat->m_flFadeMaxAlpha = readfloat();
	pSeat->m_flFadeDuration = readfloat();
	pSeat->m_flFadeHold = readfloat();
	pSeat->m_flFadeStyle = readbyte();
	pSeat->m_flFadeTime = 0.0f;

	if (pSeat->m_flFadeStyle & EVF_FADEDROM) {
		pSeat->m_flFadeAlpha = 1.0f;
	} else {
		pSeat->m_flFadeAlpha = 0.0f;
	}

	pSeat->m_iFadeActive = TRUE;
}
